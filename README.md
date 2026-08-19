# ModelBar

Tiny macOS menu-bar **viewer**: see which local LLM LM Studio or Ollama reports, plus foreign `llama-server` / `mlx_lm.server` / `ds4-server` processes.

**Pre-alpha. Source-only. Read-only.** ModelBar does not load, unload, import, or kill anything. There is no signed or notarized downloadable binary.

Clone: `https://github.com/fgomsan/modelbar.git`

## What it inspects

- LM Studio: HTTP `GET` on `127.0.0.1:1234` (`/api/v1/models`, then `/api/v0/models`). `lms ls` / `lms ps` only if nothing accepts TCP on `:1234` **and** `ps` already shows an LM Studio process (any `lms` command auto-starts LM Studio when it is not running; ModelBar never triggers that). LM Studio installed but not running is reported as “not running”, not as unknown. On some Macs `lms` dies with an invalid passkey / Bionic auth error; listing still works via HTTP.
- Ollama: HTTP `GET` on `127.0.0.1:11434` (`/api/tags` and `/api/ps`, independently). Does not follow `OLLAMA_HOST`.
- Processes: `ps` (stdout/stderr drained so a large process list cannot stall). Idle `mlx_lm.server` is noted; a heavy one, or a foreign `llama-server` not owned by LM Studio’s own binary, is listed under In RAM. LM Studio’s own `llama-server` under `.lmstudio/` is not treated as foreign. `ds4-server` is not treated as a generic `llama-server`.
- DS4 (DeepSeek V4 Flash): always-on-disk row from the `ds4flash.gguf` symlink in `MODELBAR_DS4_DIR` (default `~/Desktop/Trabajos Claude/ds4`), using the target file size and a short name, not the 200-character GGUF filename. In RAM only when `pgrep -x ds4-server` is confirmed **and** HTTP `GET 127.0.0.1:8000/v1/models` returns JSON (`pgrep` timeout is not loaded). Process up but `:8000` not ready is a “starting” note, not a loaded row. The disk row stays visible while it is in RAM. Click warns; ModelBar never starts, stops, or POSTs to DS4, and never calls `icua-ram`.
- Loose GGUF in a short list of roots (including shards): `~/models`, `~/.cache/huggingface/hub`, `~/.lmstudio/models` only when the LMS catalog is not available, plus `MODELBAR_GGUF_DIRS` (colon-separated, tildes and spaces allowed). Click explains how to open it in LM Studio or llama.cpp. Same inode or resolved path as an LMS/DS4/Ollama catalog row is dropped (symlink and target count as one). Hugging Face `blobs/` is not walked. This is not a whole-disk crawl.

If LMS, Ollama, or `ps` cannot be inspected, the DS4 GGUF was not seen, and nothing is in RAM, the bar shows `?` (unknown), not `—` (idle). A DS4 disk row is enough inventory to stay idle (`—`) when LMS and Ollama are down. If `ds4-server` is up but `:8000` is not ready, the bar stays `—` and the tooltip/menu say “starting”, not “nothing loaded”. If something is in RAM, the bar shows its name and the “cannot inspect” note appears in the menu and tooltip.

## What it does not do

- No POST to LMS, Ollama, `:8000`, `:8080`, or `:8090`
- No `lms load` / `lms unload`, and no `lms` call at all unless LM Studio is already running
- Does not import, move, or delete model files
- Does not start or kill `llama-server` / `mlx_lm.server` / `ds4-server`, and does not call `icua-ram`
- Skips Ollama cloud tags (`:cloud`, `.cloud`, `-cloud`) and rows with `remote_model` / `remote_host`

## Sizes

- LM Studio: `size_bytes` (on-disk file size). RSS of its `llama-server` can be much larger.
- Ollama In RAM: `size` from `/api/ps` (memory, labeled RAM).
- Ollama On disk: `size` from `/api/tags` (file size, labeled disk).
- DS4 On disk: size of the GGUF target behind `ds4flash.gguf`.
- DS4 In RAM: RSS of `ds4-server` when known. If RSS is missing, no size is shown (not the GGUF file size).

## Install

```bash
git clone https://github.com/fgomsan/modelbar.git
cd modelbar
chmod +x build.sh
./build.sh
open ModelBar.app
```

Requires macOS 14+, Apple Silicon, and `swiftc` (Xcode Command Line Tools).

Optional login item (this app’s own LaunchAgent label only). Quit ModelBar first if it is already open, or you will get two menu-bar icons. The agent sets `MODELBAR_DS4_DIR` and `MODELBAR_GGUF_DIRS` (the login item does not inherit your shell). Extra GGUF folders: add them to `MODELBAR_GGUF_DIRS` in `~/Library/LaunchAgents/com.fgs.model-bar.plist`, colon-separated, then reload the agent.

```bash
chmod +x install-login.sh
./install-login.sh
```

Remove the login item:

```bash
launchctl bootout "gui/$(id -u)/com.fgs.model-bar"
rm -f "$HOME/Library/LaunchAgents/com.fgs.model-bar.plist"
```

## License

MIT. Free to use, copy, and change.

If ModelBar is useful, you can [support it on Buy Me a Coffee](https://buymeacoffee.com/fgomsan).
