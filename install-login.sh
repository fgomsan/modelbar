#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
"$ROOT/build.sh"

DEST="$HOME/Applications"
mkdir -p "$DEST"
rm -rf "$DEST/ModelBar.app"
cp -R "$ROOT/ModelBar.app" "$DEST/ModelBar.app"

LABEL="com.fgs.model-bar"
mkdir -p "$HOME/Library/LaunchAgents"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
BIN="$DEST/ModelBar.app/Contents/MacOS/ModelBar"

# Optional: export MODELBAR_DS4_DIR, MODELBAR_GGUF_DIRS, and/or
# MODELBAR_OMLX_PORT before running this script if you want the login
# item to see those. A clean LM Studio / Ollama / oMLX setup does not
# need them (oMLX port comes from ~/.omlx/settings.json).
optional_env=""
if [[ -n "${MODELBAR_DS4_DIR:-}" ]]; then
	optional_env+="
		<key>MODELBAR_DS4_DIR</key>
		<string>${MODELBAR_DS4_DIR}</string>"
fi
if [[ -n "${MODELBAR_GGUF_DIRS:-}" ]]; then
	optional_env+="
		<key>MODELBAR_GGUF_DIRS</key>
		<string>${MODELBAR_GGUF_DIRS}</string>"
fi
if [[ -n "${MODELBAR_OMLX_PORT:-}" ]]; then
	optional_env+="
		<key>MODELBAR_OMLX_PORT</key>
		<string>${MODELBAR_OMLX_PORT}</string>"
fi

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${LABEL}</string>
	<key>ProgramArguments</key>
	<array>
		<string>${BIN}</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>KeepAlive</key>
	<false/>
	<key>EnvironmentVariables</key>
	<dict>
		<key>HOME</key>
		<string>${HOME}</string>
		<key>PATH</key>
		<string>${HOME}/.lmstudio/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>${optional_env}
	</dict>
</dict>
</plist>
EOF

UID_NUM="$(id -u)"
launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/${UID_NUM}" "$PLIST"
echo "installed login item → $DEST/ModelBar.app"
