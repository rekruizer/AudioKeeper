#!/bin/bash

echo "🔨 Building AudioKeeper release version..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
rm -rf build/
rm -rf AudioKeeper.app

# Build release version
xcodebuild -project AudioKeeper.xcodeproj \
           -scheme AudioKeeper \
           -configuration Release \
           -derivedDataPath build \
           clean build

# Check build success
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Copy app to current directory
    cp -R build/Build/Products/Release/AudioKeeper.app ./
    
    echo "📦 App ready: AudioKeeper.app"
    echo "📏 Size: $(du -sh AudioKeeper.app | cut -f1)"
else
    echo "❌ Build failed!"
    exit 1
fi
