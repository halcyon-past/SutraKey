#!/usr/bin/env bash
set -euo pipefail

# SutraKey DMG & ZIP Packager for Production Releases
# Generates:
#   build/SutraKey.app
#   build/SutraKey.dmg
#   build/SutraKey-v<VERSION>.dmg
#   build/SutraKey.zip
#   build/SutraKey-v<VERSION>.zip

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$ROOT_DIR/build"
APP_NAME="SutraKey"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

cd "$ROOT_DIR"

# 1. Extract version from AppConstants.swift
VERSION=$(grep 'static let version =' "$ROOT_DIR/Sources/SutraKey/Models/AppConstants.swift" | sed -E 's/.*"([^"]+)".*/\1/' | tr -d '[:space:]')
if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
fi

echo "🚀 Building SutraKey v$VERSION for Release..."
swift build -c release

# Locate release build directory
RELEASE_DIR=""
if [ -d "$ROOT_DIR/.build/arm64-apple-macosx/release" ]; then
    RELEASE_DIR="$ROOT_DIR/.build/arm64-apple-macosx/release"
elif [ -d "$ROOT_DIR/.build/release" ]; then
    RELEASE_DIR="$ROOT_DIR/.build/release"
else
    echo "❌ Error: Could not locate Swift release build directory."
    exit 1
fi

EXECUTABLE="$RELEASE_DIR/$APP_NAME"
if [ ! -f "$EXECUTABLE" ]; then
    echo "❌ Error: Executable $EXECUTABLE not found."
    exit 1
fi

# 2. Assemble .app bundle inside build/
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources/Binaries"

cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/Sources/SutraKey/Resources/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Copy SPM Resource Bundle if present
if [ -d "$RELEASE_DIR/SutraKey_SutraKey.bundle" ]; then
    cp -R "$RELEASE_DIR/SutraKey_SutraKey.bundle" "$APP_BUNDLE/Contents/Resources/"
fi

# Copy AppIcon.icns
if [ -f "$ROOT_DIR/.build/assets/AppIcon.icns" ]; then
    cp "$ROOT_DIR/.build/assets/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
fi

# Copy MenuBarIcon images
ASSETS_DIR="$ROOT_DIR/Sources/SutraKey/Resources/Assets.xcassets"
if [ -d "$ASSETS_DIR/MenuBarIcon.imageset" ]; then
    cp "$ASSETS_DIR/MenuBarIcon.imageset/MenuBarIcon@1x.png" "$APP_BUNDLE/Contents/Resources/MenuBarIcon.png" 2>/dev/null || true
    cp "$ASSETS_DIR/MenuBarIcon.imageset/MenuBarIcon@2x.png" "$APP_BUNDLE/Contents/Resources/MenuBarIcon@2x.png" 2>/dev/null || true
    cp "$ASSETS_DIR/MenuBarIcon.imageset/MenuBarIcon@1x.png" "$APP_BUNDLE/Contents/Resources/MenuBarIcon@1x.png" 2>/dev/null || true
fi

# Bundle yt-dlp & ffmpeg if available
if [ -f "$HOME/.local/share/sutrakey/bin/yt-dlp" ]; then
    cp "$HOME/.local/share/sutrakey/bin/yt-dlp" "$APP_BUNDLE/Contents/Resources/Binaries/yt-dlp"
    chmod +x "$APP_BUNDLE/Contents/Resources/Binaries/yt-dlp"
elif [ -f "/opt/homebrew/bin/yt-dlp" ]; then
    cp "/opt/homebrew/bin/yt-dlp" "$APP_BUNDLE/Contents/Resources/Binaries/yt-dlp"
    chmod +x "$APP_BUNDLE/Contents/Resources/Binaries/yt-dlp"
fi

FFMPEG_SYS="$(which ffmpeg 2>/dev/null || true)"
if [ -n "$FFMPEG_SYS" ] && [ -x "$FFMPEG_SYS" ]; then
    cp "$FFMPEG_SYS" "$APP_BUNDLE/Contents/Resources/Binaries/ffmpeg"
    chmod +x "$APP_BUNDLE/Contents/Resources/Binaries/ffmpeg"
fi

# Bundle custom yt-dlp plugins
if [ -d "$ROOT_DIR/Sources/SutraKey/Resources/yt_dlp_plugins" ]; then
    cp -R "$ROOT_DIR/Sources/SutraKey/Resources/yt_dlp_plugins" "$APP_BUNDLE/Contents/Resources/"
fi

chmod -R u+w "$APP_BUNDLE"
xattr -cr "$APP_BUNDLE" 2>/dev/null || true

# 3. Code Signing
SIGN_IDENTITY="-"
SK_KEYCHAIN="$HOME/Library/Keychains/sutrakey.keychain-db"
if [ -f "$SK_KEYCHAIN" ]; then
    security unlock-keychain -p "sutrakey" "$SK_KEYCHAIN" 2>/dev/null || true
    SIGN_IDENTITY="SutraKey CodeSign"
    echo "🔏 Signing application bundle with persistent identity '$SIGN_IDENTITY' via dedicated keychain..."
elif security find-certificate -c "SutraKey CodeSign" >/dev/null 2>&1; then
    SIGN_IDENTITY="SutraKey CodeSign"
    echo "🔏 Signing application bundle with persistent identity '$SIGN_IDENTITY'..."
else
    echo "🔏 Signing application bundle (ad-hoc)..."
fi
codesign --force --deep --sign "$SIGN_IDENTITY" "$APP_BUNDLE"

# 4. Generate DMG Installer
echo "💿 Packaging DMG for $APP_NAME v$VERSION..."
DMG_NAME="SutraKey.dmg"
VERSIONED_DMG_NAME="SutraKey-v$VERSION.dmg"
DMG_OUTPUT="$BUILD_DIR/$DMG_NAME"
VERSIONED_DMG_OUTPUT="$BUILD_DIR/$VERSIONED_DMG_NAME"

STAGING_DIR="/tmp/SutraKey_DMG_Staging"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"

cp -R "$APP_BUNDLE" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_OUTPUT"

cp "$DMG_OUTPUT" "$VERSIONED_DMG_OUTPUT"
rm -rf "$STAGING_DIR"

# 5. Generate ZIP Archive for In-Place Updates
echo "📦 Packaging ZIP archive..."
ZIP_OUTPUT="$BUILD_DIR/SutraKey.zip"
VERSIONED_ZIP_OUTPUT="$BUILD_DIR/SutraKey-v$VERSION.zip"

ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_OUTPUT"
cp "$ZIP_OUTPUT" "$VERSIONED_ZIP_OUTPUT"

# 6. Compute Checksum
DMG_SHA256=$(shasum -a 256 "$VERSIONED_DMG_OUTPUT" | awk '{print $1}')
echo ""
echo "======================================================="
echo "🎉 SUTRAKEY RELEASE PACKAGES GENERATED SUCCESSFULLY!"
echo "   Version:     v$VERSION"
echo "   DMG Asset:   $DMG_OUTPUT"
echo "   Tagged DMG:  $VERSIONED_DMG_OUTPUT"
echo "   Tagged ZIP:  $VERSIONED_ZIP_OUTPUT"
echo "   DMG SHA256:  $DMG_SHA256"
echo "======================================================="
