#!/bin/bash
# Builds "Now What.app" as an ad-hoc-signed bundle so EventKit (TCC) and
# launch-at-login (SMAppService) work. Usage: ./build.sh [--release] [--run]
set -euo pipefail

cd "$(dirname "$0")"

CONFIG="debug"
RUN=false
for arg in "$@"; do
    case "$arg" in
        --release) CONFIG="release" ;;
        --run) RUN=true ;;
    esac
done

APP_NAME="Now What"
EXECUTABLE="NowWhat"
# Read straight from Info.plist so the signing identity always matches the bundle.
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' Resources/Info.plist)"
OUT="build/$APP_NAME.app"

if [ ! -f Resources/AppIcon.icns ]; then
    echo "==> Generating app icon"
    ./tools/make_icon.sh
fi

echo "==> swift build -c $CONFIG"
swift build -c "$CONFIG"

BIN_PATH="$(swift build -c "$CONFIG" --show-bin-path)/$EXECUTABLE"

echo "==> Assembling $OUT"
rm -rf "$OUT"
mkdir -p "$OUT/Contents/MacOS" "$OUT/Contents/Resources"
cp "$BIN_PATH" "$OUT/Contents/MacOS/$EXECUTABLE"
cp Resources/Info.plist "$OUT/Contents/Info.plist"
printf 'APPL????' > "$OUT/Contents/PkgInfo"
if [ -f Resources/AppIcon.icns ]; then
    cp Resources/AppIcon.icns "$OUT/Contents/Resources/AppIcon.icns"
fi

echo "==> Ad-hoc code signing ($BUNDLE_ID)"
codesign --force --sign - --identifier "$BUNDLE_ID" "$OUT"

echo "==> Done: $OUT"

if [ "$RUN" = true ]; then
    echo "==> Launching"
    open "$OUT"
fi
