import AppKit
import Darwin
import Foundation

private enum L {
    static let prefKey = "language"

    static var pref: String {
        UserDefaults.standard.string(forKey: prefKey) ?? "system"
    }

    static var es: Bool {
        switch pref {
        case "es": return true
        case "en": return false
        default:
            let tag = Locale.preferredLanguages.first ?? Locale.current.identifier
            return tag.hasPrefix("es")
        }
    }

    static var idle: String { es ? "Nada cargado" : "Nothing loaded" }
    static var scanning: String { es ? "Buscando modelos…" : "Scanning models…" }
    static var inRAM: String { es ? "En RAM" : "In RAM" }
    static var onDisk: String { es ? "En disco" : "On disk" }
    static var noneOnDisk: String { es ? "Ningún modelo en disco" : "No models on disk" }
    static var gguf: String { es ? "GGUF en disco" : "GGUF on disk" }
    static var refresh: String { es ? "Actualizar" : "Refresh" }
    static var quit: String { es ? "Salir" : "Quit" }
    static var support: String { es ? "♡  Apoyar ModelBar" : "♡  Support ModelBar" }
    static var language: String { es ? "Idioma" : "Language" }
    static var systemLanguage: String { es ? "Sistema" : "System" }
    static var unknown: String { es ? "Estado desconocido" : "Status unknown" }
    static var unavailable: String { es ? "Backend no disponible" : "Backend unavailable" }
    static var disk: String { es ? "disco" : "disk" }
    static var ram: String { es ? "RAM" : "RAM" }
    static var lmsHTTPAuth: String {
        es
            ? "LMS HTTP 401: token o desactiva Require Authentication"
            : "LMS HTTP 401: set a token or turn off Require Authentication"
    }
    static var lmsNoHTTP: String {
        es
            ? "LM Studio: no responde en :1234 (ni lms)"
            : "LM Studio: no response on :1234 (or lms)"
    }
    static var lmsOff: String {
        es
            ? "LM Studio: no está en marcha (:1234 cerrado)"
            : "LM Studio: not running (:1234 closed)"
    }
    static var psFailed: String {
        es ? "ps: no se pudieron listar procesos" : "ps: could not list processes"
    }
    static var mlxIdle: String { es ? "mlx_lm.server inactivo (sin pesos)" : "mlx_lm.server idle (no weights)" }
    static var viewerTitle: String { es ? "ModelBar solo informa" : "ModelBar is a viewer" }
    static var viewerBody: String {
        es
            ? "No carga ni quita modelos. Ábrelo en LM Studio o Ollama si quieres usarlo."
            : "It does not load or unload models. Open it in LM Studio or Ollama to use it."
    }
    static var ggufTitle: String { es ? "Este GGUF no está en LM Studio ni Ollama" : "This GGUF is not in LM Studio or Ollama" }
    static var ggufBody: String {
        es
            ? "ModelBar no va a importar, mover ni arrancar un servidor. Ábrelo en LM Studio (Import model) o con llama.cpp."
            : "ModelBar will not import, move, or start a server. Open it in LM Studio (Import model) or llama.cpp."
    }
    static var foreignTitle: String { es ? "Proceso ajeno" : "Foreign process" }
    static func foreignBody(_ names: String) -> String {
        es
            ? "Está fuera de LM Studio/Ollama: \(names).\n\nQuítalo en la app que lo cargó. ModelBar no va a matar ese proceso."
            : "It is outside LM Studio/Ollama: \(names).\n\nUnload it in the app that loaded it. ModelBar will not kill that process."
    }
    static var ds4Starting: String { es ? "ds4-server arrancando" : "ds4-server starting" }
    static var ds4Title: String { es ? "DeepSeek V4 Flash es ajeno" : "DeepSeek V4 Flash is foreign" }
    static var ds4Body: String {
        es
            ? "ModelBar no va a arrancar ni matar ds4-server. Cárgalo o quítalo con la herramienta que lo arrancó."
            : "ModelBar will not start or kill ds4-server. Load or unload it with the tool that started it."
    }
    static var ok: String { es ? "Entendido" : "OK" }
}

private enum BackendStatus {
    case available
    case unavailable(String)
    case unknown(String)

    var isUnknown: Bool {
        if case .unknown = self { return true }
        return false
    }

    var allowsInventory: Bool {
        if case .available = self { return true }
        return false
    }

    var label: String {
        switch self {
        case .available: return ""
        case .unavailable(let s), .unknown(let s): return s
        }
    }
}

private enum HTTPOutcome {
    case json([String: Any])
    case httpStatus(Int)
    case timeout
    case noConnect
    case failed(String)
}

enum SizeKind {
    case disk
    case ram
}

struct LoadedModel {
    let runtime: String
    let key: String
    let label: String
    let short: String
    let identifier: String
    let badge: String
    let bytes: Int64
    let managed: Bool
    let sizeKind: SizeKind
}

struct DiskModel {
    let runtime: String
    let key: String
    let label: String
    let short: String
    let badge: String
    let loaded: Bool
    let path: String?
    let bytes: Int64
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let scanQueue = DispatchQueue(label: "com.fgs.model-bar.scan")
    private var timer: Timer?
    private var scanning = true
    private var scanGeneration: UInt64 = 0
    private var lastLoaded: [LoadedModel] = []
    private var lastDisk: [DiskModel] = []
    private var lastIdleNotes: [String] = []
    private var lmsStatus: BackendStatus = .unknown(L.unknown)
    private var ollamaStatus: BackendStatus = .unknown(L.unknown)
    private var processesUnknown = false
    private var scanInFlight = false
    private var lastDS4OnDisk = false

    private var lms: String { NSHomeDirectory() + "/.lmstudio/bin/lms" }
    private let ollamaHost = "http://127.0.0.1:11434"
    private let lmsHTTP = "http://127.0.0.1:1234"
    private let ds4HTTP = "http://127.0.0.1:8000"
    private let ds4Key = "ds4-flash"
    private let ds4Label = "DeepSeek V4 Flash"
    private let ds4Short = "Flash"
    private let httpSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        config.httpMaximumConnectionsPerHost = 4
        config.connectionProxyDictionary = [
            "HTTPEnable": false,
            "HTTPSEnable": false,
            "SOCKSEnable": false,
        ]
        let queue = OperationQueue()
        queue.name = "com.fgs.model-bar.http"
        queue.maxConcurrentOperationCount = 4
        queue.qualityOfService = .userInitiated
        return URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "cpu", accessibilityDescription: "Models")
            button.imagePosition = .imageLeading
            button.title = "—"
        }
        rebuildMenu()
        scanModels(force: true)
        timer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [weak self] _ in
            self?.scanModels(force: false)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    @objc private func refreshNow() {
        scanModels(force: true)
    }

    private func scanModels(force: Bool) {
        if !force, statusItem.button?.isHighlighted == true { return }
        if scanInFlight, !force { return }
        scanInFlight = true
        scanGeneration += 1
        let gen = scanGeneration
        scanQueue.async {
            let snap = self.captureSnapshot()
            DispatchQueue.main.async {
                if gen == self.scanGeneration {
                    self.scanInFlight = false
                }
                guard gen == self.scanGeneration else { return }
                self.applySnapshot(snap)
                self.applyTitle()
                self.rebuildMenu()
            }
        }
    }

    private struct Snapshot {
        let loaded: [LoadedModel]
        let disk: [DiskModel]
        let lms: BackendStatus
        let ollama: BackendStatus
        let idleNotes: [String]
        let processesUnknown: Bool
    }

    private func applySnapshot(_ snap: Snapshot) {
        scanning = false
        lmsStatus = snap.lms
        ollamaStatus = snap.ollama
        lastLoaded = snap.loaded
        lastDisk = snap.disk
        lastIdleNotes = snap.idleNotes
        processesUnknown = snap.processesUnknown
        lastDS4OnDisk = snap.disk.contains { $0.runtime == "DS4" }
    }

    private var inventoryUnknown: Bool {
        processesUnknown || lmsStatus.isUnknown || ollamaStatus.isUnknown
    }

    private var ds4Starting: Bool {
        lastIdleNotes.contains(L.ds4Starting)
    }

    private var noBackendInventory: Bool {
        !lmsStatus.allowsInventory && !ollamaStatus.allowsInventory && !lastDS4OnDisk
    }

    private func captureSnapshot() -> Snapshot {
        var loaded: [LoadedModel] = []
        var disk: [DiskModel] = []
        let unmanaged = unmanagedProcesses()
        let lms = snapshotLMS(
            loaded: &loaded,
            disk: &disk,
            lmsRunning: unmanaged.unknown ? nil : unmanaged.lmsRunning
        )
        let ollama = snapshotOllama(loaded: &loaded, disk: &disk)
        let ds4 = snapshotDS4(
            loaded: &loaded,
            disk: &disk,
            processAlive: unmanaged.ds4Running,
            rss: unmanaged.ds4RSS
        )
        loaded.append(contentsOf: unmanaged.blocking)
        disk.append(contentsOf: scanGGUFs(includeLMSModels: true))
        disk.append(contentsOf: scanLMSFolders(already: disk))
        disk = dedupLooseGGUFs(disk)
        disk = markLoaded(disk, loaded: loaded)
        disk.sort { $0.label.localizedCaseInsensitiveCompare($1.label) == .orderedAscending }
        var notes = unmanaged.idle
        if unmanaged.unknown { notes.insert(L.psFailed, at: 0) }
        if let note = ds4.starting { notes.append(note) }
        return Snapshot(
            loaded: loaded,
            disk: disk,
            lms: lms,
            ollama: ollama,
            idleNotes: notes,
            processesUnknown: unmanaged.unknown
        )
    }

    private func applyTitle() {
        let shown = lastLoaded
        if shown.isEmpty {
            if ds4Starting {
                statusItem.button?.title = "—"
                statusItem.button?.toolTip = L.ds4Starting
                return
            }
            if lastDisk.isEmpty, inventoryUnknown || noBackendInventory {
                statusItem.button?.title = "?"
                statusItem.button?.toolTip = titleNotes().joined(separator: "\n")
                return
            }
            statusItem.button?.title = "—"
            statusItem.button?.toolTip = L.idle
            return
        }
        let names = shown.map(\.short).joined(separator: "+")
        statusItem.button?.title = names
        statusItem.button?.toolTip = shown.map { model in
            let reported = Self.sizeLabel(model.bytes)
            let unit = model.sizeKind == .ram ? L.ram : L.disk
            let extra = reported.isEmpty ? "" : " · \(reported) \(unit)"
            return "\(model.label) (\(model.badge))\(extra)"
        }.joined(separator: "\n")
    }

    private func titleNotes() -> [String] {
        [lmsStatus.label, ollamaStatus.label].filter { !$0.isEmpty } + lastIdleNotes
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let loaded = lastLoaded
        let disk = lastDisk

        if scanning {
            let item = NSMenuItem(title: L.scanning, action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else if loaded.isEmpty {
            let item = NSMenuItem(title: emptyReason(), action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            let head = NSMenuItem(title: L.inRAM, action: nil, keyEquivalent: "")
            head.isEnabled = false
            menu.addItem(head)
            for model in loaded {
                let item = NSMenuItem(
                    title: "\(model.label)\(Self.sizeSuffix(model.bytes, kind: model.sizeKind))  [\(model.badge)]",
                    action: model.runtime == "DS4"
                        ? #selector(warnDS4(_:))
                        : (model.managed ? #selector(warnViewer(_:)) : #selector(warnForeign(_:))),
                    keyEquivalent: ""
                )
                item.target = self
                item.representedObject = model
                item.isEnabled = true
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())
        let diskHead = NSMenuItem(title: L.onDisk, action: nil, keyEquivalent: "")
        diskHead.isEnabled = false
        menu.addItem(diskHead)

        let catalogs = disk.filter { $0.runtime != "llama.cpp" && !$0.loaded }
        let ggufs = disk.filter { $0.runtime == "llama.cpp" }
        if catalogs.isEmpty, ggufs.isEmpty, !scanning {
            let item = NSMenuItem(title: L.noneOnDisk, action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        } else {
            for model in catalogs {
                let action: Selector = model.runtime == "DS4" ? #selector(warnDS4(_:)) : #selector(warnViewer(_:))
                menu.addItem(diskItem(model, action: action))
            }
        }

        if !ggufs.isEmpty {
            menu.addItem(.separator())
            let head = NSMenuItem(title: L.gguf, action: nil, keyEquivalent: "")
            head.isEnabled = false
            menu.addItem(head)
            for model in ggufs {
                menu.addItem(diskItem(model, action: #selector(warnGGUF(_:))))
            }
        }

        let notes = titleNotes()
        if !notes.isEmpty {
            menu.addItem(.separator())
            for note in notes {
                let err = NSMenuItem(title: note, action: nil, keyEquivalent: "")
                err.isEnabled = false
                menu.addItem(err)
            }
        }

        menu.addItem(.separator())
        menu.addItem(languageMenu())
        let refreshItem = NSMenuItem(title: L.refresh, action: #selector(refreshNow), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        let support = NSMenuItem(title: L.support, action: #selector(openSupport(_:)), keyEquivalent: "")
        support.target = self
        menu.addItem(support)
        menu.addItem(NSMenuItem(title: L.quit, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func emptyReason() -> String {
        if ds4Starting { return L.ds4Starting }
        if lastDisk.isEmpty, inventoryUnknown { return L.unknown }
        if lastDisk.isEmpty, noBackendInventory { return L.unavailable }
        return L.idle
    }

    private func diskItem(_ model: DiskModel, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(
            title: "\(model.label)\(Self.sizeSuffix(model.bytes, kind: .disk))  [\(model.badge)]",
            action: action,
            keyEquivalent: ""
        )
        item.target = self
        item.representedObject = model
        item.isEnabled = true
        return item
    }

    private func languageMenu() -> NSMenuItem {
        let parent = NSMenuItem(title: L.language, action: nil, keyEquivalent: "")
        let sub = NSMenu()
        sub.autoenablesItems = false
        for (raw, title) in [("system", L.systemLanguage), ("en", "English"), ("es", "Español")] {
            let item = NSMenuItem(title: title, action: #selector(setLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = raw
            item.state = L.pref == raw ? .on : .off
            sub.addItem(item)
        }
        parent.submenu = sub
        return parent
    }

    @objc private func openSupport(_ sender: Any?) {
        guard let url = URL(string: "https://buymeacoffee.com/fgomsan") else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func setLanguage(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String else { return }
        UserDefaults.standard.set(raw, forKey: L.prefKey)
        applyTitle()
        rebuildMenu()
    }

    @objc private func warnViewer(_ sender: Any?) {
        alert(L.viewerTitle, L.viewerBody)
    }

    @objc private func warnGGUF(_ sender: Any?) {
        alert(L.ggufTitle, L.ggufBody)
    }

    @objc private func warnForeign(_ sender: NSMenuItem) {
        guard let model = sender.representedObject as? LoadedModel else { return }
        alert(L.foreignTitle, L.foreignBody(model.label))
    }

    @objc private func warnDS4(_ sender: Any?) {
        alert(L.ds4Title, L.ds4Body)
    }

    private func alert(_ title: String, _ body: String) {
        NSApp.activate(ignoringOtherApps: true)
        let a = NSAlert()
        a.messageText = title
        a.informativeText = body
        a.alertStyle = .informational
        a.addButton(withTitle: L.ok)
        a.runModal()
    }

    // lmsRunning: true/false = ps saw (or did not see) an LM Studio process; nil = ps could not tell.
    // `lms` is only run when LM Studio is already running: any lms command auto-starts LM Studio
    // if it is not running, and a viewer must never do that.
    private func snapshotLMS(loaded: inout [LoadedModel], disk: inout [DiskModel], lmsRunning: Bool?) -> BackendStatus {
        let http = lmsHTTPCatalog()
        switch http {
        case .json(let obj):
            appendLMSRows(Self.objects(obj["models"]), loaded: &loaded, disk: &disk, fromCLI: false, ps: [])
            return .available
        case .httpStatus(let code) where code == 401 || code == 403:
            return .unknown(L.lmsHTTPAuth)
        case .timeout, .failed, .httpStatus:
            return .unknown(L.lmsNoHTTP)
        case .noConnect:
            break
        }
        guard FileManager.default.isExecutableFile(atPath: lms) else {
            // App can be open with the developer server off and no `lms` CLI.
            // That is not "not running": on-disk models in ~/.lmstudio/models still count.
            if lmsRunning == true { return .unknown(L.lmsNoHTTP) }
            return .unavailable(L.lmsOff)
        }
        guard let lmsRunning else {
            return .unknown(L.lmsNoHTTP)
        }
        if !lmsRunning {
            return .unavailable(L.lmsOff)
        }
        do {
            let rows = try lmsJSON(["ls", "--json"])
            do {
                let ps = try lmsJSON(["ps", "--json"])
                appendLMSRows(rows, loaded: &loaded, disk: &disk, fromCLI: true, ps: ps)
                return .available
            } catch {
                appendLMSRows(rows, loaded: &loaded, disk: &disk, fromCLI: true, ps: [])
                return .unknown(L.unknown + " · LMS")
            }
        } catch {
            return .unknown(L.lmsNoHTTP)
        }
    }

    private func appendLMSRows(
        _ rows: [[String: Any]],
        loaded: inout [LoadedModel],
        disk: inout [DiskModel],
        fromCLI: Bool,
        ps: [[String: Any]]
    ) {
        let loadedKeys = Set(ps.compactMap { ($0["modelKey"] as? String) ?? ($0["identifier"] as? String) })
        for row in rows {
            guard let key = lmsRowKey(row) else { continue }
            let isEmbed = lmsRowEmbed(row, key: key)
            let vision = lmsRowVision(row, key: key)
            let format = (row["format"] as? String) ?? (row["compatibility_type"] as? String)
            let bytes = Self.int64(row["size_bytes"] ?? row["sizeBytes"])
            let label = displayName(
                key,
                fallback: (row["display_name"] as? String) ?? (row["displayName"] as? String)
            )
            let ident = lmsRowIdentifier(row, key: key, ps: ps)
            let isLoaded = fromCLI
                ? (loadedKeys.contains(key) || loadedKeys.contains(ident))
                : lmsRowLoaded(row)
            if isLoaded {
                loaded.append(
                    LoadedModel(
                        runtime: "LMS",
                        key: key,
                        label: label,
                        short: shortName(key, embed: isEmbed),
                        identifier: ident,
                        badge: Self.badge(runtime: "LMS", format: format, vision: vision, extra: isEmbed ? "embed" : nil),
                        bytes: bytes,
                        managed: true,
                        sizeKind: .disk
                    )
                )
            }
            disk.append(
                DiskModel(
                    runtime: "LMS",
                    key: key,
                    label: label,
                    short: shortName(key, embed: isEmbed),
                    badge: Self.badge(runtime: "LMS", format: format, vision: vision, extra: isEmbed ? "embed" : nil),
                    loaded: isLoaded,
                    path: row["path"] as? String,
                    bytes: bytes
                )
            )
        }
    }

    private func lmsRowKey(_ row: [String: Any]) -> String? {
        let raw = (row["id"] as? String) ?? (row["key"] as? String) ?? (row["modelKey"] as? String)
        guard let raw, !raw.isEmpty else { return nil }
        return raw
    }

    private func lmsRowIdentifier(_ row: [String: Any], key: String, ps: [[String: Any]]) -> String {
        let instances = Self.objects(row["loaded_instances"] ?? row["loadedInstances"])
        if let id = instances.first?["id"] as? String, !id.isEmpty {
            return id
        }
        if let ident = ps.first(where: { ($0["modelKey"] as? String) == key })?["identifier"] as? String, !ident.isEmpty {
            return ident
        }
        return key
    }

    private func lmsRowLoaded(_ row: [String: Any]) -> Bool {
        let state = (row["state"] as? String ?? "").lowercased()
        if state == "loaded" { return true }
        if state == "not-loaded" || state == "unloaded" { return false }
        let instances = Self.objects(row["loaded_instances"] ?? row["loadedInstances"])
        return !instances.isEmpty
    }

    private func lmsRowVision(_ row: [String: Any], key: String) -> Bool {
        let type = (row["type"] as? String ?? "").lowercased()
        if type == "vlm" { return true }
        if let caps = row["capabilities"] as? [String] {
            return caps.contains { $0.lowercased().contains("vision") }
        }
        if let caps = row["capabilities"] as? [String: Any], let vision = caps["vision"] as? Bool {
            return vision
        }
        if let vision = row["vision"] as? Bool { return vision }
        return isVision(key)
    }

    private func lmsRowEmbed(_ row: [String: Any], key: String) -> Bool {
        let type = (row["type"] as? String ?? "").lowercased()
        return type.contains("embed") || isEmbedName(key)
    }

    private func snapshotOllama(loaded: inout [LoadedModel], disk: inout [DiskModel]) -> BackendStatus {
        let tagsOut = jsonGET(ollamaHost + "/api/tags")
        let psOut = jsonGET(ollamaHost + "/api/ps")
        var sawJSON = false
        var unknown = false
        var unavailable = false

        switch psOut {
        case .json(let obj):
            sawJSON = true
            let running = obj["models"] as? [[String: Any]] ?? []
            for row in running {
                guard let name = row["name"] as? String, !isCloudRow(row) else { continue }
                let embed = isEmbedName(name)
                loaded.append(
                    LoadedModel(
                        runtime: "Ollama",
                        key: name,
                        label: ollamaDisplayName(name),
                        short: ollamaShort(name, embed: embed),
                        identifier: name,
                        badge: Self.badge(
                            runtime: "Ollama",
                            format: ((row["details"] as? [String: Any])?["format"] as? String),
                            vision: isVision(name),
                            extra: embed ? "embed" : nil
                        ),
                        bytes: Self.int64(row["size"]),
                        managed: true,
                        sizeKind: .ram
                    )
                )
            }
        case .noConnect:
            unavailable = true
        case .timeout, .failed, .httpStatus:
            unknown = true
        }

        switch tagsOut {
        case .json(let obj):
            sawJSON = true
            let models = obj["models"] as? [[String: Any]] ?? []
            let loadedNames = Set(loaded.filter { $0.runtime == "Ollama" }.map(\.key))
            for row in models {
                guard let name = row["name"] as? String, !isCloudRow(row) else { continue }
                let embed = isEmbedName(name)
                disk.append(
                    DiskModel(
                        runtime: "Ollama",
                        key: name,
                        label: ollamaDisplayName(name),
                        short: ollamaShort(name, embed: embed),
                        badge: Self.badge(
                            runtime: "Ollama",
                            format: ((row["details"] as? [String: Any])?["format"] as? String),
                            vision: isVision(name),
                            extra: embed ? "embed" : nil
                        ),
                        loaded: loadedNames.contains(name),
                        path: nil,
                        bytes: Self.int64(row["size"])
                    )
                )
            }
        case .noConnect:
            unavailable = true
        case .timeout, .failed, .httpStatus:
            unknown = true
        }

        if unknown { return .unknown(L.unknown + " · Ollama") }
        if sawJSON { return .available }
        if unavailable { return .unavailable(L.unavailable + " · Ollama") }
        return .unknown(L.unknown + " · Ollama")
    }

    // GET-only. A closed :8000 is "not loaded", not an error. Never start ds4-server or call icua-ram.
    private func snapshotDS4(
        loaded: inout [LoadedModel],
        disk: inout [DiskModel],
        processAlive: Bool?,
        rss: Int64
    ) -> (path: String?, starting: String?) {
        let onDisk = ds4DiskModel()
        if let onDisk { disk.append(onDisk) }
        let ready = jsonGET(ds4HTTP + "/v1/models")
        let httpReady: Bool
        if case .json = ready { httpReady = true } else { httpReady = false }
        if httpReady, processAlive == true {
            loaded.append(
                LoadedModel(
                    runtime: "DS4",
                    key: ds4Key,
                    label: ds4Label,
                    short: ds4Short,
                    identifier: ds4Key,
                    badge: Self.badge(runtime: "DS4", format: "gguf", vision: false, extra: nil),
                    bytes: rss,
                    managed: false,
                    sizeKind: .ram
                )
            )
            return (onDisk?.path, nil)
        }
        if processAlive == true {
            return (onDisk?.path, L.ds4Starting)
        }
        return (onDisk?.path, nil)
    }

    // Optional. Unset or missing path → no DS4 disk row; LMS/Ollama still work.
    private func ds4Directory() -> String? {
        let env = ProcessInfo.processInfo.environment["MODELBAR_DS4_DIR"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let env, !env.isEmpty else { return nil }
        return (env as NSString).expandingTildeInPath
    }

    private func ds4DiskModel() -> DiskModel? {
        guard let dir = ds4Directory() else { return nil }
        let link = (dir as NSString).appendingPathComponent("ds4flash.gguf")
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: link, isDirectory: &isDir), !isDir.boolValue else {
            return nil
        }
        let resolved = URL(fileURLWithPath: link).resolvingSymlinksInPath()
        guard FileManager.default.fileExists(atPath: resolved.path, isDirectory: &isDir), !isDir.boolValue else {
            return nil
        }
        let bytes = Int64((try? resolved.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
        guard bytes > 0 else { return nil }
        return DiskModel(
            runtime: "DS4",
            key: ds4Key,
            label: ds4Label,
            short: ds4Short,
            badge: Self.badge(runtime: "DS4", format: "gguf", vision: false, extra: nil),
            loaded: false,
            path: resolved.path,
            bytes: bytes
        )
    }

    private func unmanagedProcesses() -> (
        blocking: [LoadedModel], idle: [String], unknown: Bool, lmsRunning: Bool, ds4Running: Bool?, ds4RSS: Int64
    ) {
        let ds4 = ds4Process()
        let result = run(["/bin/ps", "-axo", "rss=,command="], timeout: 2)
        guard result.status == 0 else { return ([], [], true, false, ds4.running, ds4.rss) }
        var blocking: [LoadedModel] = []
        var idle: [String] = []
        var mlxHeavy = false
        var lmsRunning = false
        for line in result.output.split(separator: "\n") {
            guard let parsed = Self.parsePS(String(line)) else { continue }
            let cmd = parsed.cmd
            if isLMSOwned(cmd) {
                lmsRunning = true
                continue
            }
            if isUnmanagedMLX(cmd) {
                if mlxBlocksLoad(rssKB: parsed.rssKB, cmd: cmd) {
                    mlxHeavy = true
                    blocking.append(unmanaged("mlx_lm", "mlx_lm.server", "MLX"))
                } else if !mlxHeavy, !idle.contains(L.mlxIdle) {
                    idle.append(L.mlxIdle)
                }
                continue
            }
            if isUnmanagedLlamaServer(cmd) {
                blocking.append(unmanaged("llama.cpp", "llama-server", "GGUF"))
            }
        }
        if mlxHeavy {
            idle.removeAll { $0 == L.mlxIdle }
        }
        var unique: [LoadedModel] = []
        var seen = Set<String>()
        for model in blocking where seen.insert(model.runtime + "\0" + model.key).inserted {
            unique.append(model)
        }
        return (unique, idle, false, lmsRunning, ds4.running, ds4.rss)
    }

    // `pgrep -x` matches p_comm, not argv. Scanning `ps` command= tokens false-positives
    // on shells / `pgrep -x ds4-server` that only mention the name.
    private func ds4Process() -> (running: Bool?, rss: Int64) {
        let listed = run(["/usr/bin/pgrep", "-x", "ds4-server"], timeout: 2)
        if listed.output == "timeout" { return (nil, 0) }
        guard listed.status == 0 else { return (false, 0) }
        let pids = listed.output.split(whereSeparator: \.isWhitespace).compactMap { Int($0) }
        guard !pids.isEmpty else { return (false, 0) }
        var rss: Int64 = 0
        for pid in pids {
            let row = run(["/bin/ps", "-p", String(pid), "-o", "rss="], timeout: 2)
            if row.status == 0, let kb = Int64(row.output.trimmingCharacters(in: .whitespacesAndNewlines)), kb > rss {
                rss = kb
            }
        }
        return (true, rss * 1024)
    }

    static func parsePS(_ line: String) -> (rssKB: Int64, cmd: String)? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard let space = trimmed.firstIndex(where: { $0.isWhitespace }) else { return nil }
        guard let rss = Int64(trimmed[..<space]) else { return nil }
        let cmd = String(trimmed[space...]).trimmingCharacters(in: .whitespaces)
        if cmd.isEmpty { return nil }
        return (rss, cmd)
    }

    private func commandTokens(_ cmd: String) -> [String] {
        cmd.split(whereSeparator: \.isWhitespace).map(String.init)
    }

    private func pathLast(_ token: String) -> String {
        URL(fileURLWithPath: token).lastPathComponent
    }

    private func isLMSOwned(_ cmd: String) -> Bool {
        let low = cmd.lowercased()
        return low.contains(".lmstudio/") || low.contains("lm studio.app") || low.contains("bionic.app")
    }

    private func isInterpreter(_ token: String) -> Bool {
        let bin = pathLast(token).lowercased()
        return bin.hasPrefix("python") || bin == "env"
    }

    private func isUnmanagedMLX(_ cmd: String) -> Bool {
        let tokens = commandTokens(cmd)
        guard let first = tokens.first else { return false }
        if pathLast(first) == "mlx_lm.server" { return true }
        guard isInterpreter(first) else { return false }
        for (i, token) in tokens.enumerated() {
            if pathLast(token) == "mlx_lm.server" { return true }
            if (token == "-m" || token == "--module"), i + 1 < tokens.count, tokens[i + 1] == "mlx_lm.server" {
                return true
            }
        }
        return false
    }

    private func mlxBlocksLoad(rssKB: Int64, cmd: String) -> Bool {
        if rssKB > 2 * 1024 * 1024 { return true }
        return mlxHasWeights(commandTokens(cmd))
    }

    private func mlxHasWeights(_ tokens: [String]) -> Bool {
        for (i, token) in tokens.enumerated() {
            if token.hasPrefix("--model="), token != "--model=" { return true }
            if token.hasPrefix("--path="), token != "--path=" { return true }
            guard i + 1 < tokens.count else { continue }
            let val = tokens[i + 1]
            if token == "--model" || token == "--path" {
                if !val.hasPrefix("-"), val != "mlx_lm.server" { return true }
            }
            if token == "-m" {
                if val == "mlx_lm.server" { continue }
                if !val.hasPrefix("-") { return true }
            }
        }
        return false
    }

    private func isUnmanagedLlamaServer(_ cmd: String) -> Bool {
        guard let first = commandTokens(cmd).first else { return false }
        return pathLast(first) == "llama-server"
    }

    private func unmanaged(_ runtime: String, _ label: String, _ format: String) -> LoadedModel {
        LoadedModel(
            runtime: runtime,
            key: label,
            label: label,
            short: runtime == "mlx_lm" ? "MLX" : "GGUF",
            identifier: label,
            badge: "\(runtime) · \(format)",
            bytes: 0,
            managed: false,
            sizeKind: .disk
        )
    }

    private func markLoaded(_ disk: [DiskModel], loaded: [LoadedModel]) -> [DiskModel] {
        disk.map { model in
            let isLoaded = loaded.contains {
                $0.managed && $0.runtime == model.runtime && ($0.key == model.key || $0.identifier == model.key)
            }
            return DiskModel(
                runtime: model.runtime,
                key: model.key,
                label: model.label,
                short: model.short,
                badge: model.badge,
                loaded: isLoaded,
                path: model.path,
                bytes: model.bytes
            )
        }
    }

    private func lmsHTTPCatalog() -> HTTPOutcome {
        var last: HTTPOutcome = .noConnect
        var emptyJSON = false
        // v0 is the downloaded-library catalog. Empty `/api/v1/models` (or OpenAI
        // `/v1/models` with nothing loaded) must not hide v0.
        for path in ["/api/v0/models", "/api/v1/models", "/v1/models"] {
            let outcome = jsonGET(lmsHTTP + path)
            switch outcome {
            case .json(let obj):
                let rows = Self.objects(obj["models"])
                if !rows.isEmpty { return .json(["models": rows]) }
                let data = Self.objects(obj["data"])
                if !data.isEmpty { return .json(["models": data]) }
                emptyJSON = true
            case .httpStatus(let code) where code == 401 || code == 403:
                return outcome
            default:
                last = outcome
            }
        }
        if emptyJSON { return .json(["models": []]) }
        return last
    }

    private func ggufRoots(includeLMSModels: Bool) -> [String] {
        var roots = [NSHomeDirectory() + "/models"]
        if includeLMSModels {
            roots.append(NSHomeDirectory() + "/.lmstudio/models")
        }
        roots.append(NSHomeDirectory() + "/.cache/huggingface/hub")
        let extra = ProcessInfo.processInfo.environment["MODELBAR_GGUF_DIRS"] ?? ""
        for part in extra.split(separator: ":") {
            let trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                roots.append((trimmed as NSString).expandingTildeInPath)
            }
        }
        var seen = Set<String>()
        return roots.compactMap { raw in
            let path = URL(fileURLWithPath: raw).standardizedFileURL.path
            guard seen.insert(path).inserted else { return nil }
            return path
        }
    }

    private func scanGGUFs(includeLMSModels: Bool) -> [DiskModel] {
        var groups: [String: (url: URL, bytes: Int64)] = [:]
        var seenFile = Set<String>()
        let fm = FileManager.default
        let keys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey]
        for root in ggufRoots(includeLMSModels: includeLMSModels) {
            var isDir: ObjCBool = false
            guard fm.fileExists(atPath: root, isDirectory: &isDir), isDir.boolValue,
                  let enumerator = fm.enumerator(
                    at: URL(fileURLWithPath: root),
                    includingPropertiesForKeys: keys,
                    options: [.skipsHiddenFiles]
                  ) else { continue }
            while let url = enumerator.nextObject() as? URL {
                let vals = try? url.resourceValues(forKeys: Set(keys))
                if vals?.isDirectory == true {
                    if shouldSkipGGUFDir(url.lastPathComponent) { enumerator.skipDescendants() }
                    continue
                }
                guard url.pathExtension.lowercased() == "gguf" else { continue }
                let name = url.lastPathComponent.lowercased()
                if name.contains("mmproj") || name.contains("incomplete") { continue }
                let resolved = url.resolvingSymlinksInPath()
                guard fm.isReadableFile(atPath: resolved.path) else { continue }
                if let id = fileIdentity(resolved), !seenFile.insert(id).inserted { continue }
                let size = Int64((try? resolved.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                guard size > 0 else { continue }
                let key = ggufGroupKey(resolved, root: root)
                if let existing = groups[key] {
                    let pick = resolved.lastPathComponent < existing.url.lastPathComponent ? resolved : existing.url
                    groups[key] = (pick, existing.bytes + size)
                } else {
                    groups[key] = (resolved, size)
                }
            }
        }
        return groups.keys.sorted().compactMap { key in
            guard let group = groups[key] else { return nil }
            return DiskModel(
                runtime: "llama.cpp",
                key: key,
                label: prettyFileName(URL(fileURLWithPath: key).lastPathComponent),
                short: shortName(key, embed: false),
                badge: Self.badge(runtime: "GGUF", format: "gguf", vision: isVision(key), extra: nil),
                loaded: false,
                path: group.url.path,
                bytes: group.bytes
            )
        }
    }

    private func shouldSkipGGUFDir(_ name: String) -> Bool {
        switch name.lowercased() {
        case "blobs", "node_modules", "__pycache__", "caches":
            return true
        default:
            return false
        }
    }

    // LM Studio on Apple Silicon often stores Qwen as MLX/safetensors, not GGUF.
    // HTTP :1234 and `lms` may both be missing on a clean Mac; the folder still exists.
    private func scanLMSFolders(already: [DiskModel]) -> [DiskModel] {
        let root = NSHomeDirectory() + "/.lmstudio/models"
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: root, isDirectory: &isDir), isDir.boolValue,
              let publishers = try? fm.contentsOfDirectory(atPath: root)
        else { return [] }
        let existingKeys = Set(already.filter { $0.runtime == "LMS" }.map { $0.key.lowercased() })
        var models: [DiskModel] = []
        for pub in publishers {
            if pub.hasPrefix(".") { continue }
            let pubPath = (root as NSString).appendingPathComponent(pub)
            guard fm.fileExists(atPath: pubPath, isDirectory: &isDir), isDir.boolValue,
                  let names = try? fm.contentsOfDirectory(atPath: pubPath)
            else { continue }
            for name in names {
                if name.hasPrefix(".") { continue }
                let key = "\(pub)/\(name)"
                if existingKeys.contains(key.lowercased()) { continue }
                let dir = (pubPath as NSString).appendingPathComponent(name)
                guard fm.fileExists(atPath: dir, isDirectory: &isDir), isDir.boolValue,
                      let model = lmsFolderModel(dir: dir, key: key)
                else { continue }
                models.append(model)
            }
        }
        return models
    }

    private func lmsFolderModel(dir: String, key: String) -> DiskModel? {
        let fm = FileManager.default
        let keys: [URLResourceKey] = [.isDirectoryKey, .fileSizeKey]
        guard let enumerator = fm.enumerator(
            at: URL(fileURLWithPath: dir),
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        ) else { return nil }
        var bytes: Int64 = 0
        var sawGGUF = false
        var sawMLX = false
        while let url = enumerator.nextObject() as? URL {
            let vals = try? url.resourceValues(forKeys: Set(keys))
            if vals?.isDirectory == true {
                if shouldSkipGGUFDir(url.lastPathComponent) { enumerator.skipDescendants() }
                continue
            }
            let ext = url.pathExtension.lowercased()
            let size = Int64(vals?.fileSize ?? 0)
            if ext == "gguf" {
                sawGGUF = true
                bytes += size
            } else if ext == "safetensors" || ext == "npz" || ext == "ggml" {
                sawMLX = true
                bytes += size
            }
        }
        // GGUF-only trees are already listed by scanGGUFs.
        guard sawMLX, bytes > 0 else { return nil }
        let format = sawGGUF ? "gguf" : "mlx"
        let embed = isEmbedName(key)
        return DiskModel(
            runtime: "LMS",
            key: key,
            label: displayName(key, fallback: nil),
            short: shortName(key, embed: embed),
            badge: Self.badge(runtime: "LMS", format: format, vision: isVision(key), extra: embed ? "embed" : nil),
            loaded: false,
            path: dir,
            bytes: bytes
        )
    }

    // Prefer catalog rows (LMS / Ollama / DS4). Drop loose GGUFs that are the
    // same inode or the same resolved path, including a symlink and its target.
    private func dedupLooseGGUFs(_ disk: [DiskModel]) -> [DiskModel] {
        var seen = Set<String>()
        var kept: [DiskModel] = []
        for model in disk where model.runtime != "llama.cpp" {
            if let path = model.path, let id = fileIdentity(URL(fileURLWithPath: path)) {
                seen.insert(id)
            }
            kept.append(model)
        }
        for model in disk where model.runtime == "llama.cpp" {
            if let path = model.path, let id = fileIdentity(URL(fileURLWithPath: path)), !seen.insert(id).inserted {
                continue
            }
            kept.append(model)
        }
        return kept
    }

    private func fileIdentity(_ url: URL) -> String? {
        let resolved = url.resolvingSymlinksInPath().standardizedFileURL
        if let vals = try? resolved.resourceValues(forKeys: [.fileResourceIdentifierKey]),
           let ident = vals.fileResourceIdentifier
        {
            return String(describing: ident)
        }
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resolved.path, isDirectory: &isDir), !isDir.boolValue else {
            return nil
        }
        return resolved.path
    }

    private func ggufGroupKey(_ url: URL, root: String) -> String {
        var name = url.deletingPathExtension().lastPathComponent
        if let range = name.range(of: #"-(\d{5})-of-(\d{5})$"#, options: .regularExpression) {
            name = String(name[..<range.lowerBound])
        }
        let parent = url.deletingLastPathComponent().path
        let rootPath = URL(fileURLWithPath: root).standardizedFileURL.path
        if parent.hasPrefix(rootPath) {
            let rel = String(parent.dropFirst(rootPath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return rel.isEmpty ? name : rel + "/" + name
        }
        return parent + "/" + name
    }

    private func prettyFileName(_ key: String) -> String {
        key.replacingOccurrences(of: "-", with: " ").replacingOccurrences(of: "_", with: " ")
    }

    private func isCloudRow(_ row: [String: Any]) -> Bool {
        if let name = row["name"] as? String, isCloudName(name) { return true }
        if let remote = row["remote_model"] as? String, !remote.isEmpty { return true }
        if let host = row["remote_host"] as? String, !host.isEmpty { return true }
        return false
    }

    private func isCloudName(_ name: String) -> Bool {
        let k = name.lowercased()
        return k.hasSuffix(":cloud") || k.hasSuffix(".cloud") || k.hasSuffix("-cloud")
    }

    private func isEmbedName(_ name: String) -> Bool {
        let k = name.lowercased()
        return k.contains("embed") || k.contains("nomic") || k.contains("minilm") || k.contains("bge-") || k.contains("mxbai")
    }

    private func isVision(_ key: String) -> Bool {
        let k = key.lowercased()
        return k.contains("vlm") || k.contains("vision")
    }

    private func shortName(_ key: String, embed: Bool) -> String {
        if embed { return "emb" }
        let last = key.split { $0 == "/" }.last.map(String.init) ?? key
        if last.count <= 16 { return last }
        return String(last.prefix(16))
    }

    private func displayName(_ key: String, fallback: String?) -> String {
        if let fallback, !fallback.isEmpty, fallback != key { return fallback }
        return key.split { $0 == "/" }.last.map(String.init) ?? key
    }

    private func ollamaDisplayName(_ name: String) -> String {
        if name.hasPrefix("library/") { return String(name.dropFirst("library/".count)) }
        return name
    }

    private func ollamaShort(_ name: String, embed: Bool) -> String {
        if embed { return "emb" }
        let n = ollamaDisplayName(name)
        if n.count <= 20 { return n }
        return String(n.prefix(20))
    }

    static func badge(runtime: String, format: String?, vision: Bool, extra: String?) -> String {
        var parts = [runtime]
        let fmt = (format ?? "").lowercased()
        if fmt.contains("gguf") { parts.append("GGUF") }
        else if fmt.contains("mlx") { parts.append("MLX") }
        else if fmt.contains("safetensor") { parts.append("safetensors") }
        if vision { parts.append("VLM") }
        if let extra { parts.append(extra) }
        var seen = Set<String>()
        return parts.filter { seen.insert($0).inserted }.joined(separator: " · ")
    }

    static func int64(_ value: Any?) -> Int64 {
        if let n = value as? Int64 { return n }
        if let n = value as? Int { return Int64(n) }
        if let n = value as? NSNumber { return n.int64Value }
        if let n = value as? Double { return Int64(n) }
        return 0
    }

    static func sizeLabel(_ bytes: Int64) -> String {
        guard bytes > 0 else { return "" }
        let g = Double(bytes) / 1_073_741_824.0
        if g < 1 { return String(format: "%.0f MiB", Double(bytes) / 1_048_576.0) }
        if g < 10 { return String(format: "%.1f GiB", g) }
        return String(format: "%.0f GiB", g)
    }

    static func sizeSuffix(_ bytes: Int64, kind: SizeKind) -> String {
        let label = sizeLabel(bytes)
        guard !label.isEmpty else { return "" }
        let unit = kind == .ram ? L.ram : L.disk
        return "  \(label) \(unit)"
    }

    private func lmsJSON(_ args: [String]) throws -> [[String: Any]] {
        let result = run([lms] + args, timeout: 4)
        if result.status != 0 {
            throw simpleError(result.output.isEmpty ? L.lmsNoHTTP : result.output)
        }
        let data = Data(result.output.utf8)
        let obj = try JSONSerialization.jsonObject(with: data)
        if let arr = obj as? [[String: Any]] { return arr }
        if let arr = obj as? [Any] { return arr.compactMap { $0 as? [String: Any] } }
        throw simpleError(result.output)
    }

    private func jsonGET(_ urlString: String) -> HTTPOutcome {
        guard let url = URL(string: urlString) else { return .failed(L.unavailable) }
        var req = URLRequest(url: url, timeoutInterval: 2)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.cachePolicy = .reloadIgnoringLocalCacheData
        return httpCall(req)
    }

    private func httpCall(_ request: URLRequest) -> HTTPOutcome {
        let sem = DispatchSemaphore(value: 0)
        var payload: Data?
        var status = 0
        var urlError: URLError?
        let task = httpSession.dataTask(with: request) { data, resp, err in
            payload = data
            status = (resp as? HTTPURLResponse)?.statusCode ?? 0
            urlError = err as? URLError
            sem.signal()
        }
        task.resume()
        let waited = sem.wait(timeout: .now() + max(request.timeoutInterval, 1) + 1)
        if waited == .timedOut || task.state == .running {
            task.cancel()
            return .timeout
        }
        if status >= 400 {
            return .httpStatus(status)
        }
        if let urlError {
            switch urlError.code {
            case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                return .noConnect
            case .timedOut:
                return .timeout
            default:
                if status == 0 {
                    return .failed(urlError.localizedDescription)
                }
            }
        }
        if status == 0, payload == nil {
            return .noConnect
        }
        if let payload, !payload.isEmpty {
            if let obj = try? JSONSerialization.jsonObject(with: payload) as? [String: Any] {
                return .json(obj)
            }
            if let arr = try? JSONSerialization.jsonObject(with: payload) as? [Any] {
                return .json(["data": arr])
            }
        }
        if status > 0, status < 400 {
            return .failed("HTTP 2xx without JSON")
        }
        return .failed(L.unavailable)
    }

    static func objects(_ value: Any?) -> [[String: Any]] {
        if let rows = value as? [[String: Any]] { return rows }
        if let rows = value as? [Any] { return rows.compactMap { $0 as? [String: Any] } }
        return []
    }

    private func run(_ args: [String], timeout: TimeInterval) -> (status: Int32, output: String) {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: args[0])
        proc.arguments = Array(args.dropFirst())
        var env = ProcessInfo.processInfo.environment
        env["HOME"] = NSHomeDirectory()
        env.removeValue(forKey: "OLLAMA_HOST")
        proc.environment = env
        let out = Pipe()
        let err = Pipe()
        proc.standardOutput = out
        proc.standardError = err
        // Both pipes are drained by their readability handlers while the child runs, so a large
        // process list cannot fill the pipe and stall the child. Each handler is the only reader
        // of its pipe (in order); it signals EOF once, and the handler is removed only after that.
        let lock = NSLock()
        var stdout = Data()
        var stderr = Data()
        let outEOF = DispatchSemaphore(value: 0)
        let errEOF = DispatchSemaphore(value: 0)
        out.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if chunk.isEmpty {
                handle.readabilityHandler = nil
                outEOF.signal()
                return
            }
            lock.lock()
            stdout.append(chunk)
            lock.unlock()
        }
        err.fileHandleForReading.readabilityHandler = { handle in
            let chunk = handle.availableData
            if chunk.isEmpty {
                handle.readabilityHandler = nil
                errEOF.signal()
                return
            }
            lock.lock()
            stderr.append(chunk)
            lock.unlock()
        }
        do {
            try proc.run()
        } catch {
            out.fileHandleForReading.readabilityHandler = nil
            err.fileHandleForReading.readabilityHandler = nil
            return (1, error.localizedDescription)
        }
        let deadline = Date().addingTimeInterval(timeout)
        while proc.isRunning, Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if proc.isRunning {
            proc.terminate()
            var waits = 0
            while proc.isRunning, waits < 10 {
                Thread.sleep(forTimeInterval: 0.05)
                waits += 1
            }
            if proc.isRunning {
                kill(proc.processIdentifier, SIGKILL)
                Thread.sleep(forTimeInterval: 0.05)
            }
            out.fileHandleForReading.readabilityHandler = nil
            err.fileHandleForReading.readabilityHandler = nil
            return (1, "timeout")
        }
        // Child exited: wait (bounded) for each handler to see EOF, then stop them.
        _ = outEOF.wait(timeout: .now() + 1)
        _ = errEOF.wait(timeout: .now() + 1)
        out.fileHandleForReading.readabilityHandler = nil
        err.fileHandleForReading.readabilityHandler = nil
        lock.lock()
        let outText = String(data: stdout, encoding: .utf8) ?? ""
        let errText = String(data: stderr, encoding: .utf8) ?? ""
        lock.unlock()
        let text = outText.trimmingCharacters(in: .whitespacesAndNewlines)
        if proc.terminationStatus == 0 { return (0, text) }
        let errTrim = errText.trimmingCharacters(in: .whitespacesAndNewlines)
        return (proc.terminationStatus, text.isEmpty ? errTrim : text)
    }

    private func simpleError(_ message: String) -> NSError {
        let clipped = message.split(separator: "\n").prefix(2).joined(separator: " · ")
        return NSError(domain: "ModelBar", code: 1, userInfo: [NSLocalizedDescriptionKey: String(clipped.prefix(80))])
    }
}

@main
enum ModelBarMain {
    static let delegate = AppDelegate()
    static func main() {
        let app = NSApplication.shared
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
