#!/bin/bash

echo "🔨 Building AudioKeeper release version..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Disable automatic log file generation
export XCODE_BUILD_DISABLE_DUPLICATE_OUTPUT_WARNINGS=1
export ENABLE_LOGGING=NO
export ENABLE_LOGGING_FOR_DEBUGGING=NO

# Clean previous builds
rm -rf build/
rm -rf AudioKeeper.app
rm -rf *.dmg

# Build release version with explicit destination
echo "📁 Current directory: $(pwd)"
echo "📁 Project files:"
ls -la AudioKeeper.xcodeproj/

echo "🔨 Building with xcodebuild..."
xcodebuild -project AudioKeeper.xcodeproj \
           -scheme AudioKeeper \
           -configuration Release \
           -derivedDataPath build \
           -destination "platform=macOS,arch=arm64" \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGN_STYLE=Automatic \
           ENABLE_LOGGING=NO \
           ENABLE_LOGGING_FOR_DEBUGGING=NO \
           XCODE_BUILD_DISABLE_DUPLICATE_OUTPUT_WARNINGS=YES \
           -allowProvisioningUpdates \
           -skipMacroValidation \
           clean build

# Check build success
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Check what was built
    echo "📁 Build output:"
    ls -la build/Build/Products/Release/
    
    # Copy app to current directory
    if [ -d "build/Build/Products/Release/AudioKeeper.app" ]; then
        echo "📦 Copying real app..."
        cp -R build/Build/Products/Release/AudioKeeper.app ./
    else
        echo "❌ No AudioKeeper.app found in build output!"
        echo "📁 Available files:"
        find build/ -name "*.app" -type d
        exit 1
    fi
    
    # Code sign the app (if certificates are available)
    if [ -n "$APPLE_CERTIFICATE" ] && [ -n "$APPLE_CERTIFICATE_PASSWORD" ]; then
        echo "🔐 Code signing app with Developer ID..."
        
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
        echo "🔐 Code signing app with ad-hoc certificate..."
        
        # Sign with ad-hoc certificate (no real certificate needed)
        codesign --force --sign "-" AudioKeeper.app
        
        # Sign all frameworks and libraries inside the app
        find AudioKeeper.app -name "*.framework" -exec codesign --force --sign "-" {} \;
        find AudioKeeper.app -name "*.dylib" -exec codesign --force --sign "-" {} \;
        
        # Remove quarantine attribute to allow execution
        xattr -d com.apple.quarantine AudioKeeper.app 2>/dev/null || true
        
        # Add extended attributes to allow execution
        xattr -c AudioKeeper.app 2>/dev/null || true
        xattr -w com.apple.quarantine "0081;$(date +%s);AudioKeeper;|com.apple.quarantine" AudioKeeper.app 2>/dev/null || true
        
        # Verify the signature
        codesign --verify --verbose AudioKeeper.app
    fi
    
    echo "📦 App ready: AudioKeeper.app"
    echo "📏 Size: $(du -sh AudioKeeper.app | cut -f1)"
else
    echo "❌ Build failed!"
    exit 1
fi
