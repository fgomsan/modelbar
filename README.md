# ModelBar

Tiny macOS menu-bar **viewer**: see which local LLM LM Studio or Ollama reports, plus foreign `llama-server` / `mlx_lm.server` processes.

**Pre-alpha. Source-only. Read-only.** ModelBar does not load, unload, import, or kill anything. There is no signed or notarized downloadable binary.

Clone: `https://github.com/fgomsan/modelbar.git`

## What it inspects

- LM Studio: HTTP `GET` on `127.0.0.1:1234` (`/api/v1/models`, then `/api/v0/models`). `lms ls` / `lms ps` only if nothing accepts TCP on `:1234`. On some Macs `lms` dies with an invalid passkey / Bionic auth error; listing still works via HTTP.
- Ollama: HTTP `GET` on `127.0.0.1:11434` (`/api/tags` and `/api/ps`, independently). Does not follow `OLLAMA_HOST`.
- Processes: `ps` (stdout/stderr drained so a large process list cannot stall). Idle `mlx_lm.server` is noted; a heavy one, or a foreign `llama-server` not owned by LM Studio’s own binary, is listed under In RAM. LM Studio’s own `llama-server` under `.lmstudio/` is not treated as foreign.
- Loose GGUF under `~/models` (including shards). Click explains how to open it in LM Studio or llama.cpp.

If LMS, Ollama, or `ps` cannot be inspected, the bar shows `?` (unknown), not `—` (idle).

## What it does not do

- No POST to LMS, Ollama, `:8080`, or `:8090`
- No `lms load` / `lms unload`
- Does not import, move, or delete model files
- Does not start or kill `llama-server` / `mlx_lm.server`
- Skips Ollama cloud tags (`:cloud`, `.cloud`, `-cloud`) and rows with `remote_model` / `remote_host`

## Sizes

- LM Studio: `size_bytes` (on-disk file size). RSS of its `llama-server` can be much larger.
- Ollama In RAM: `size` from `/api/ps` (memory, labeled RAM).
- Ollama On disk: `size` from `/api/tags` (file size, labeled disk).

## Install

```bash
git clone https://github.com/fgomsan/modelbar.git
cd modelbar
chmod +x build.sh
./build.sh
open ModelBar.app
```

Requires macOS 14+, Apple Silicon, and `swiftc` (Xcode Command Line Tools).

Optional login item (this app’s own LaunchAgent label only):

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
