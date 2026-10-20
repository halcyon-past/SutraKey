#!/usr/bin/env bash
set -euo pipefail

# Build SutraKey AppIcon.icns from generated iconset
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$ROOT_DIR/Sources/SutraKey/Resources/Assets.xcassets"
APPICONSET="$ASSETS_DIR/AppIcon.appiconset"
BUILD_DIR="$ROOT_DIR/.build/assets"
ICNS_FILE="$BUILD_DIR/AppIcon.icns"

echo "📦 Packaging SutraKey AppIcon.icns..."

mkdir -p "$BUILD_DIR"
ICONSET_TMP="$BUILD_DIR/AppIcon.iconset"
rm -rf "$ICONSET_TMP"
mkdir -p "$ICONSET_TMP"

# Copy standard icon sizes to .iconset structure for iconutil
cp "$APPICONSET/icon_16x16@1x.png" "$ICONSET_TMP/icon_16x16.png"
cp "$APPICONSET/icon_16x16@2x.png" "$ICONSET_TMP/icon_16x16@2x.png"
cp "$APPICONSET/icon_32x32@1x.png" "$ICONSET_TMP/icon_32x32.png"
cp "$APPICONSET/icon_32x32@2x.png" "$ICONSET_TMP/icon_32x32@2x.png"
cp "$APPICONSET/icon_128x128@1x.png" "$ICONSET_TMP/icon_128x128.png"
cp "$APPICONSET/icon_128x128@2x.png" "$ICONSET_TMP/icon_128x128@2x.png"
cp "$APPICONSET/icon_256x256@1x.png" "$ICONSET_TMP/icon_256x256.png"
cp "$APPICONSET/icon_256x256@2x.png" "$ICONSET_TMP/icon_256x256@2x.png"
cp "$APPICONSET/icon_512x512@1x.png" "$ICONSET_TMP/icon_512x512.png"
cp "$APPICONSET/icon_512x512@2x.png" "$ICONSET_TMP/icon_512x512@2x.png"

if command -v iconutil >/dev/null 2>&1; then
    iconutil -c icns "$ICONSET_TMP" -o "$ICNS_FILE"
    echo "✅ Successfully generated $ICNS_FILE"
else
    echo "⚠️ iconutil not found, skipping .icns compilation"
fi
