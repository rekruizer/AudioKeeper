#!/bin/bash
set -e

echo "💿 Creating DMG installer..."

# Navigate to project root
cd "$(dirname "$0")/.."

APP_NAME="AudioKeeper"
APP_PATH="./AudioKeeper.app"
# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ AudioKeeper.app not found. Run build_release.sh first."
    exit 1
fi

# Name the installer after the actual binary, never a nearby or dirty git tag.
RAW_VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")
if [[ ! "$RAW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
   [ "${APP_VERSION:-$RAW_VERSION}" != "$RAW_VERSION" ] || \
   [ "${DMG_VERSION:-v$RAW_VERSION}" != "v$RAW_VERSION" ]; then
    echo "❌ App, release and DMG versions do not match"
    exit 1
fi
VERSION_WITH_V="v${RAW_VERSION}"
DMG_NAME="${APP_NAME}-${VERSION_WITH_V}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION_WITH_V}"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Copy app
cp -R "$APP_PATH" "$TEMP_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"

# Create README for DMG
cat > "$TEMP_DIR/README.txt" << EOF
AudioKeeper ${VERSION_WITH_V}

Installation:
1. Drag AudioKeeper.app to Applications folder
2. Launch AudioKeeper from Applications or Spotlight
3. Look for the headphone icon in your menu bar

IMPORTANT - Security Warning:
If macOS shows a security warning:
Review System Settings → Privacy & Security for an "Open Anyway" option.
Only allow this app if you trust the release source.

This build is not notarized by Apple.

For more information, visit:
https://github.com/rekruizer/AudioKeeper
EOF

# Create DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_NAME"

# Sign DMG if certificate is available
if [ -n "$APPLE_CERTIFICATE" ] && [ -n "$APPLE_CERTIFICATE_PASSWORD" ]; then
    echo "🔐 Signing DMG with Developer ID..."
    codesign --force --sign "Developer ID Application" "$DMG_NAME"
else
    echo "🔐 DMG created without signing (ad-hoc mode)..."
    # Don't sign DMG at all - let macOS handle it naturally
    # This is how it worked in earlier versions
fi

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo "✅ DMG created: $DMG_NAME"
echo "📏 Size: $(du -sh "$DMG_NAME" | cut -f1)"
