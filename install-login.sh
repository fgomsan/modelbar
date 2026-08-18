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
		<string>${HOME}/.lmstudio/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
		<key>MODELBAR_DS4_DIR</key>
		<string>${HOME}/Desktop/Trabajos Claude/ds4</string>
		<key>MODELBAR_GGUF_DIRS</key>
		<string>${HOME}/models</string>
	</dict>
</dict>
</plist>
EOF

UID_NUM="$(id -u)"
launchctl bootout "gui/${UID_NUM}/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/${UID_NUM}" "$PLIST"
echo "installed login item → $DEST/ModelBar.app"
