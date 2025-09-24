#!/bin/bash

echo "💿 Creating DMG installer..."

# Navigate to project root
cd "$(dirname "$0")/.."

APP_NAME="AudioKeeper"
APP_PATH="./AudioKeeper.app"
DMG_NAME="${APP_NAME}-v1.0.dmg"
VOLUME_NAME="${APP_NAME}"

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

# Create DMG
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_NAME"

# Clean up temporary files
rm -rf "$TEMP_DIR"

echo "✅ DMG created: $DMG_NAME"
