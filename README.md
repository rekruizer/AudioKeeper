# 🎧 AudioKeeper

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Automatically maintains your preferred audio devices** - no more manual switching when you connect/disconnect headphones, speakers, or microphones.

[![Download Latest](https://img.shields.io/badge/Download-Latest%20Release-blue?style=for-the-badge&logo=github)](https://github.com/rekruizer/AudioKeeper/releases/latest)

## 🚀 Quick Start

1. **Download** → **Install** → **Launch**
2. Find the 🎧 icon in your menu bar
3. Select your preferred devices and enjoy!

## ✨ Features

- 🎧 **Menu Bar Only** - Clean interface, no Dock clutter
- 🔄 **Automatic Device Management** - Restores your preferred devices instantly
- 💾 **Persistent Settings** - Remembers your preferences between sessions
- ⚡ **Real-time Monitoring** - Instant response to device connections

## 📦 Installation

### Option 1: Homebrew (Recommended)
```bash
brew install --cask audiokeeper
```

### Option 2: Manual Download
1. Download from [GitHub Releases](https://github.com/rekruizer/AudioKeeper/releases)
2. Open DMG and drag to Applications
3. **Right-click** AudioKeeper.app → **"Open"** → **"Open"** (bypasses security warning)

### Option 3: Terminal
```bash
# After installing, run this command:
sudo xattr -d com.apple.quarantine /Applications/AudioKeeper.app
```

> **Note:** macOS may show a security warning. This is normal for unsigned apps. Use any method above to allow the app to run.

## 🛠️ Development

```bash
# Clone and build
git clone https://github.com/rekruizer/AudioKeeper.git
cd AudioKeeper
open AudioKeeper.xcodeproj
# Press Cmd + R in Xcode
```

**Requirements:** macOS 13.0+, Xcode 14.0+, Swift 5.7+

## 📁 Project Structure

```
AudioKeeper/
├── Sources/           # Swift source code
├── Assets.xcassets/   # App icons and resources
├── Scripts/          # Build and distribution scripts
└── Documentation/    # Detailed documentation
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🆘 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/rekruizer/AudioKeeper/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/rekruizer/AudioKeeper/discussions)