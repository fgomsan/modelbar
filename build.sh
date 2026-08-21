#!/bin/zsh
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "ModelBar only builds on macOS / ModelBar solo se compila en macOS." >&2
	exit 1
fi
if [[ "$(uname -m)" != "arm64" ]]; then
	echo "ModelBar needs Apple Silicon (arm64) / hace falta Apple Silicon (arm64)." >&2
	exit 1
fi
if ! command -v swiftc >/dev/null 2>&1; then
	echo "swiftc not found. Install Xcode Command Line Tools:" >&2
	echo "  xcode-select --install" >&2
	echo "No se encontró swiftc. Instala las Command Line Tools de Xcode:" >&2
	echo "  xcode-select --install" >&2
	exit 1
fi
if ! command -v codesign >/dev/null 2>&1; then
	echo "codesign not found. Install Xcode Command Line Tools:" >&2
	echo "  xcode-select --install" >&2
	echo "No se encontró codesign. Instala las Command Line Tools de Xcode:" >&2
	echo "  xcode-select --install" >&2
	exit 1
fi

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
echo "open \"$APP\""
echo "Bar — = nothing in RAM / nada en RAM. Open the menu / abre el menú."
