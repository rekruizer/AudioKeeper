#!/bin/bash

echo "💿 Creating DMG installer..."

# Navigate to project root
cd "$(dirname "$0")/.."

APP_NAME="AudioKeeper"
APP_PATH="./AudioKeeper.app"
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "v1.0.0")
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="${APP_NAME} ${VERSION}"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ AudioKeeper.app not found. Run build_release.sh first."
    exit 1
fi

# Create temporary directory
TEMP_DIR="./dmg_temp"
mkdir -p "$TEMP_DIR"

# Copy app
cp -R "$APP_PATH" "$TEMP_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"

# Create README for DMG
cat > "$TEMP_DIR/README.txt" << EOF
AudioKeeper ${VERSION}

Installation:
1. Drag AudioKeeper.app to Applications folder
2. Launch AudioKeeper from Applications or Spotlight
3. Look for the headphone icon in your menu bar

For more information, visit:
https://github.com/rekruizer/AudioKeeper
EOF

# Create DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_NAME"

# Sign DMG if certificate is available
if [ -n "$APPLE_CERTIFICATE" ] && [ -n "$APPLE_CERTIFICATE_PASSWORD" ]; then
    echo "🔐 Signing DMG..."
    codesign --force --sign "Developer ID Application" "$DMG_NAME"
fi

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo "✅ DMG created: $DMG_NAME"
echo "📏 Size: $(du -sh "$DMG_NAME" | cut -f1)"
