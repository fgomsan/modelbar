#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/ModelBar.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
swiftc -O -parse-as-library "$ROOT/ModelBar.swift" \
  -target arm64-apple-macosx14.0 \
  -o "$APP/Contents/MacOS/ModelBar" \
  -framework AppKit -framework Foundation
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"
echo "built $APP"
