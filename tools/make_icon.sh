#!/bin/bash
# Renders the app icon and packages it into Resources/AppIcon.icns.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK="$(mktemp -d)"
ICONSET="$WORK/AppIcon.iconset"
MASTER="$WORK/icon_1024.png"
mkdir -p "$ICONSET"

echo "==> Rendering master icon"
swift tools/generate_icon.swift "$MASTER"

echo "==> Building iconset"
gen() { sips -z "$1" "$1" "$MASTER" --out "$ICONSET/$2" >/dev/null; }
gen 16   icon_16x16.png
gen 32   icon_16x16@2x.png
gen 32   icon_32x32.png
gen 64   icon_32x32@2x.png
gen 128  icon_128x128.png
gen 256  icon_128x128@2x.png
gen 256  icon_256x256.png
gen 512  icon_256x256@2x.png
gen 512  icon_512x512.png
cp "$MASTER" "$ICONSET/icon_512x512@2x.png"

echo "==> Converting to .icns"
mkdir -p Resources
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns

rm -rf "$WORK"
echo "==> Done: Resources/AppIcon.icns"
