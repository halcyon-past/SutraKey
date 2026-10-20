#!/usr/bin/env bash
set -euo pipefail

# SutraKey Local Packager & Installer
# Builds the production Swift release binary, packages SutraKey.app bundle,
# embeds icons & binaries, signs ad-hoc, and installs to /Applications/SutraKey.app.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="SutraKey"
TARGET_APP="/Applications/${APP_NAME}.app"

echo "🚀 Building SutraKey (Release mode)..."
cd "$ROOT_DIR"
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

echo "📦 Packaging $TARGET_APP..."
# If app is running, stop it
killall "$APP_NAME" 2>/dev/null || true

# Prepare bundle directory structure
rm -rf "$TARGET_APP"
mkdir -p "$TARGET_APP/Contents/MacOS"
mkdir -p "$TARGET_APP/Contents/Resources/Binaries"

# 1. Copy Executable
cp "$EXECUTABLE" "$TARGET_APP/Contents/MacOS/$APP_NAME"
chmod +x "$TARGET_APP/Contents/MacOS/$APP_NAME"

# 2. Copy Info.plist
cp "$ROOT_DIR/Sources/SutraKey/Resources/Info.plist" "$TARGET_APP/Contents/Info.plist"

# 3. Copy SPM Resource Bundle (Bundle.module support)
if [ -d "$RELEASE_DIR/SutraKey_SutraKey.bundle" ]; then
    cp -R "$RELEASE_DIR/SutraKey_SutraKey.bundle" "$TARGET_APP/Contents/Resources/"
fi

# 4. Copy AppIcon.icns
if [ -f "$ROOT_DIR/.build/assets/AppIcon.icns" ]; then
    cp "$ROOT_DIR/.build/assets/AppIcon.icns" "$TARGET_APP/Contents/Resources/AppIcon.icns"
fi

# 5. Copy MenuBarIcon images
ASSETS_DIR="$ROOT_DIR/Sources/SutraKey/Resources/Assets.xcassets"
if [ -d "$ASSETS_DIR/MenuBarIcon.imageset" ]; then
    cp "$ASSETS_DIR/MenuBarIcon.imageset/MenuBarIcon@1x.png" "$TARGET_APP/Contents/Resources/MenuBarIcon.png" 2>/dev/null || true
    cp "$ASSETS_DIR/MenuBarIcon.imageset/MenuBarIcon@2x.png" "$TARGET_APP/Contents/Resources/MenuBarIcon@2x.png" 2>/dev/null || true
fi

# 6. Bundle yt-dlp & ffmpeg if available locally
if [ -f "$HOME/.local/share/sutrakey/bin/yt-dlp" ]; then
    cp "$HOME/.local/share/sutrakey/bin/yt-dlp" "$TARGET_APP/Contents/Resources/Binaries/yt-dlp"
    chmod +x "$TARGET_APP/Contents/Resources/Binaries/yt-dlp"
    echo "✅ Bundled yt-dlp into $TARGET_APP/Contents/Resources/Binaries/yt-dlp"
fi

FFMPEG_SYS="$(which ffmpeg 2>/dev/null || true)"
if [ -n "$FFMPEG_SYS" ] && [ -x "$FFMPEG_SYS" ]; then
    cp "$FFMPEG_SYS" "$TARGET_APP/Contents/Resources/Binaries/ffmpeg"
    chmod +x "$TARGET_APP/Contents/Resources/Binaries/ffmpeg"
    echo "✅ Bundled ffmpeg into $TARGET_APP/Contents/Resources/Binaries/ffmpeg"
fi

# 7. Ad-hoc codesign
echo "🔏 Signing application bundle (ad-hoc)..."
codesign --force --deep --sign - "$TARGET_APP"

# 8. Clear quarantine attributes
xattr -cr "$TARGET_APP" 2>/dev/null || true

# 9. Register with LaunchServices
if [ -f "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister" ]; then
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$TARGET_APP"
fi

echo "✨ Successfully installed SutraKey to $TARGET_APP"
