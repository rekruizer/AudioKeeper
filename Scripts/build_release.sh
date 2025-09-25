#!/bin/bash

echo "🔨 Building AudioKeeper release version..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean previous builds
rm -rf build/
rm -rf AudioKeeper.app
rm -rf *.dmg

# Build release version
xcodebuild -project AudioKeeper.xcodeproj \
           -scheme AudioKeeper \
           -configuration Release \
           -derivedDataPath build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGN_STYLE=Automatic \
           ENABLE_LOGGING=NO \
           ENABLE_LOGGING_FOR_DEBUGGING=NO \
           clean build

# Check build success
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Copy app to current directory
    cp -R build/Build/Products/Release/AudioKeeper.app ./
    
    # Code sign the app (if certificates are available)
    if [ -n "$APPLE_CERTIFICATE" ] && [ -n "$APPLE_CERTIFICATE_PASSWORD" ]; then
        echo "🔐 Code signing app..."
        
        # Create temporary keychain
        security create-keychain -p "" build.keychain
        security default-keychain -s build.keychain
        security unlock-keychain -p "" build.keychain
        
        # Import certificate
        echo "$APPLE_CERTIFICATE" | base64 --decode > certificate.p12
        security import certificate.p12 -k build.keychain -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign
        
        # Sign the app
        codesign --force --sign "Developer ID Application" AudioKeeper.app
        
        # Clean up
        rm certificate.p12
        security delete-keychain build.keychain
    else
        echo "⚠️  Skipping code signing (no certificates provided)"
    fi
    
    echo "📦 App ready: AudioKeeper.app"
    echo "📏 Size: $(du -sh AudioKeeper.app | cut -f1)"
else
    echo "❌ Build failed!"
    exit 1
fi
