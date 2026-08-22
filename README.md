# ModelBar

Tiny macOS menu-bar **viewer**: which local LLM LM Studio, Ollama, or oMLX reports, plus foreign `llama-server` / `mlx_lm.server` / `ds4-server` processes.

Visor mínimo de barra de menús: qué modelo hay en RAM y qué hay en disco.

**Pre-alpha. Read-only.** Does not load, unload, import, or kill anything. The GitHub Release zip is **ad-hoc signed, not notarized** — macOS Gatekeeper will warn until we have a Developer ID.

## Download / Descarga

Apple Silicon, macOS 14+. You still need **Ollama, LM Studio, and/or oMLX**.

1. Get the zip from [Releases](https://github.com/fgomsan/modelbar/releases/latest).
2. Unzip and move `ModelBar.app` to Applications.
3. Open it. There is **no Dock icon** (menu bar only).
4. If macOS says the app cannot be opened: **right-click → Open**, or System Settings → Privacy & Security → Open Anyway.

Si macOS bloquea: clic derecho → Abrir. La barra en **—** es nada en RAM, no un fallo; abre el menú.

## Build from source / Compilar

**Need / Necesitas:** `git`, `swiftc` (Xcode Command Line Tools: `xcode-select --install`), macOS 14+, Apple Silicon.

```bash
git clone https://github.com/fgomsan/modelbar.git
cd modelbar
chmod +x build.sh
./build.sh
open ModelBar.app
```

If `swiftc` is missing, `./build.sh` tells you to run `xcode-select --install` and stops.

**First look / Al abrir**

The bar shows **—** when nothing is in RAM. That is idle, not a crash. Open the menu: **Nada en RAM · N en disco** (or *Nothing in RAM*) and the model names. Click a name: ModelBar only informs; load it in Ollama, LM Studio, or oMLX. If none of those is installed, it asks you to install one and press Refresh. It does not mention LM Studio on a Mac that does not have it.

## Start at login (optional)

Quit ModelBar first if it is already open, or you will get two menu-bar icons. The login item does not inherit your shell; it only sets `HOME` and a small `PATH` (including `~/.lmstudio/bin`). Extra folders are opt-in: export `MODELBAR_DS4_DIR` and/or `MODELBAR_GGUF_DIRS` before running the script, or add them later to `~/Library/LaunchAgents/com.fgs.model-bar.plist` (colon-separated, tildes and spaces allowed) and reload the agent. oMLX on a non-default port is picked up from `~/.omlx/settings.json` or `omlx serve --port`; override with `MODELBAR_OMLX_PORT` if you need to.

```bash
chmod +x install-login.sh
./install-login.sh
```

Remove the login item:

```bash
launchctl bootout "gui/$(id -u)/com.fgs.model-bar"
rm -f "$HOME/Library/LaunchAgents/com.fgs.model-bar.plist"
```

## What it inspects

- LM Studio: HTTP `GET` on `127.0.0.1:1234` (`/api/v0/models` first — that is the downloaded library — then `/api/v1/models` and `/v1/models`). An empty v1 response does not hide v0. `lms ls` / `lms ps` only if nothing accepts TCP on `:1234` **and** `ps` already shows an LM Studio process (any `lms` command auto-starts LM Studio when it is not running; ModelBar never triggers that). LM Studio installed but not running is reported as “not running”, not as unknown. If the app is open but the local server is off and `lms` is missing, ModelBar still lists `~/.lmstudio/models` (GGUF and MLX/safetensors). On some Macs `lms` dies with an invalid passkey / Bionic auth error; listing still works via HTTP or the on-disk folder.
- Ollama: HTTP `GET` on `127.0.0.1:11434` first (`/api/tags` and `/api/ps`). If loopback refuses, probe **this Mac’s own IPv4 addresses** on `:11434` (a server bound only to a Tailscale or LAN IP still counts). Does **not** follow a remote `OLLAMA_HOST` — that would list another machine. If HTTP still fails, list `~/.ollama/models/manifests` the same way LMS folders are listed. A running `ollama` process with no reachable `:11434` is unknown, not “not installed”.
- oMLX: HTTP `GET` only (never `POST /load` or `/unload`, never `omlx start`). Port from `MODELBAR_OMLX_PORT` / `OMLX_PORT`, then `omlx serve --port` in `ps`, then `~/.omlx/settings.json` (`server.port`). If those are missing, try `:8083` then `:8000` only when oMLX is present, and only if the JSON is actually oMLX (`owned_by: omlx` or `/v1/models/status` with `loaded` / `estimated_size`) so DS4 on `:8000` is not stolen. Prefers `GET /v1/models/status`, then `/admin/api/models`, then `/v1/models`. Loaded rows go under In RAM; the rest stay on disk. Helper / MarkItDown / hidden rows are skipped. HTTP 401 is “set a token or turn off the API key”, same idea as LMS. If HTTP is down, list `~/.omlx/models` plus `model.model_dirs` from settings (directories with `config.json` and safetensors). Process up but the port not ready is a “starting” note, not a loaded row. Click warns; ModelBar never starts, stops, or POSTs to oMLX.
- Processes: `ps` (stdout/stderr drained so a large process list cannot stall). Idle `mlx_lm.server` is noted; a heavy one, or a foreign `llama-server` not owned by LM Studio’s own binary, is listed under In RAM. LM Studio’s own `llama-server` under `.lmstudio/` is not treated as foreign. `ds4-server` is not treated as a generic `llama-server`. An `omlx` / `oMLX.app` process is not treated as `mlx_lm.server`.
- DS4 (DeepSeek V4 Flash, optional): only if `MODELBAR_DS4_DIR` is set. Then an always-on-disk row comes from the `ds4flash.gguf` symlink in that directory, using the target file size and a short name, not the 200-character GGUF filename. If the variable is unset or the path is missing, ModelBar still runs. In RAM only when `pgrep -x ds4-server` is confirmed **and** HTTP `GET 127.0.0.1:8000/v1/models` returns JSON (`pgrep` timeout is not loaded). Process up but `:8000` not ready is a “starting” note, not a loaded row. The disk row stays visible while it is in RAM. Click warns; ModelBar never starts, stops, or POSTs to DS4.
- Loose GGUF in a short list of roots (including shards): `~/models`, `~/.lmstudio/models`, `~/.cache/huggingface/hub`, plus optional `MODELBAR_GGUF_DIRS` (colon-separated, tildes and spaces allowed). Missing roots are skipped. Click explains how to open it in LM Studio or llama.cpp. Same inode or resolved path as an LMS/DS4/Ollama catalog row is dropped (symlink and target count as one). Hugging Face `blobs/` is not walked. This is not a whole-disk crawl.

If LMS, Ollama, oMLX, or `ps` cannot be inspected, nothing is on disk, and nothing is in RAM, the bar shows `?` (unknown), not `—` (idle). Models found on disk (LMS folder, Ollama manifests, oMLX library, GGUF, or a DS4 row) are enough inventory to stay idle (`—`) when the HTTP APIs are down. Idle means nothing in RAM; the tooltip and menu list what is on disk. If neither Ollama, LM Studio, nor oMLX is installed, the bar asks you to install one. If `ds4-server` is up but `:8000` is not ready, or oMLX is up but its port is not ready, the bar stays `—` and the tooltip/menu say “starting”. If something is in RAM, the bar shows its name and the “cannot inspect” note appears in the menu and tooltip.

## What it does not do

- No POST to LMS, Ollama, oMLX, `:8000`, `:8080`, `:8083`, or `:8090`
- No `lms load` / `lms unload`, and no `lms` call at all unless LM Studio is already running
- No `omlx start` / `omlx serve`, and no `POST` to `/v1/models/.../load`
- Does not import, move, or delete model files
- Does not start or kill `llama-server` / `mlx_lm.server` / `ds4-server` / `omlx`
- Skips Ollama cloud tags (`:cloud`, `.cloud`, `-cloud`) and rows with `remote_model` / `remote_host`
- Does not follow a remote `OLLAMA_HOST` (another machine’s library). Local IPs of this Mac on `:11434` are probed; subprocesses still have `OLLAMA_HOST` stripped.

## Sizes

- LM Studio: `size_bytes` (on-disk file size). RSS of its `llama-server` can be much larger.
- Ollama In RAM: `size` from `/api/ps` (memory, labeled RAM).
- Ollama On disk: `size` from `/api/tags` (file size, labeled disk). If HTTP is unreachable, blob sizes from `~/.ollama/models`.
- DS4 On disk: size of the GGUF target behind `ds4flash.gguf` (only when `MODELBAR_DS4_DIR` is set and the symlink exists).
- DS4 In RAM: RSS of `ds4-server` when known. If RSS is missing, no size is shown (not the GGUF file size).
- oMLX On disk: `estimated_size` from `/v1/models/status` (or safetensors under `~/.omlx/models`).
- oMLX In RAM: `actual_size` when oMLX reports it, otherwise `estimated_size`. If `/v1/models` has no load flag, RSS of the `omlx` process only when it is already over 2 GiB.

## License

MIT. Free to use, copy, and change.

If ModelBar is useful, you can [support it on Buy Me a Coffee](https://buymeacoffee.com/fgomsan).
