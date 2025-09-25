# 🎧 AudioKeeper

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A professional macOS menu bar application that automatically maintains your preferred audio input/output devices. Perfect for users who frequently connect/disconnect audio devices and want to keep their preferred setup.

## ✨ Features

- 🎧 **Menu Bar Only** - Clean interface, no Dock clutter
- 🔄 **Automatic Device Management** - Restores your preferred devices instantly
- 💾 **Persistent Settings** - Remembers your preferences between sessions
- 🛡️ **System Respect** - Doesn't interfere with manual audio changes
- ⚡ **Real-time Monitoring** - Instant response to device connections
- 🌍 **Bilingual** - English and Russian interface
- 🔧 **Developer Friendly** - Clean architecture, well documented

## 🚀 Quick Start

### For Users
1. **Download** the latest release from [GitHub Releases](https://github.com/rekruizer/AudioKeeper/releases)
2. **Install** AudioKeeper.app to Applications
3. **Launch** and find the headphone icon in your menu bar
4. **Configure** your preferred input/output devices
5. **Enjoy** automatic audio device management!

[![Download Latest](https://img.shields.io/badge/Download-Latest%20Release-blue?style=for-the-badge&logo=github)](https://github.com/rekruizer/AudioKeeper/releases/latest)

### Homebrew Cask (⚠️ Currently Broken)

```bash
# ⚠️ WARNING: Homebrew installation is currently broken
# The DMG contains a test app instead of the real application
# Please use manual installation below until this is fixed

# brew install --cask audiokeeper  # DON'T USE YET
```

#### ⚠️ Installation without Developer Certificate

Since this app is not signed with an Apple Developer Certificate, you'll need to allow it to run:

**Method 1: Right-click method (Recommended)**
1. Download the DMG from [Releases](https://github.com/rekruizer/AudioKeeper/releases)
2. Open the DMG and drag AudioKeeper.app to Applications
3. **Right-click** on AudioKeeper.app in Applications
4. Select **"Open"** from the context menu
5. Click **"Open"** in the security dialog

**Method 2: Terminal method**
```bash
# After installing the app, run this command:
sudo xattr -d com.apple.quarantine /Applications/AudioKeeper.app
```

**Method 3: System Preferences**
1. Go to **System Preferences** → **Security & Privacy**
2. Click **"Allow Anyway"** next to the blocked app message
3. Try opening the app again

### For Developers
```bash
# Clone the repository
git clone https://github.com/rekruizer/AudioKeeper.git
cd AudioKeeper

# Open in Xcode
open AudioKeeper.xcodeproj

# Build and run
# Press Cmd + R in Xcode
```

## 📱 Screenshots

*Menu bar interface with device selection*

## 🏗️ Project Structure

```
AudioKeeper/
├── Sources/                # Swift source code
│   ├── App/               # Main app files
│   ├── Audio/             # Audio device management
│   └── Models/            # Data models
├── Assets.xcassets/        # App icons and resources
├── Scripts/               # Build and distribution scripts
├── Documentation/         # Detailed documentation
├── AudioKeeper.xcodeproj  # Xcode project file
├── Info.plist            # App configuration
├── README.md             # English documentation
├── README_RU.md          # Russian documentation
└── LICENSE               # MIT License
```

## ⚠️ Known Issues

### Homebrew Cask Installation
- **Problem**: DMG files contain test application instead of real app
- **Status**: GitHub Actions build is failing to create proper app
- **Workaround**: Use manual installation from GitHub Releases
- **Fix**: Working on resolving Xcode build issues in CI/CD

### Manual Installation Recommended
Until the Homebrew issue is resolved, please use the manual installation method above.

## 🛠️ Development

### Requirements
- macOS 13.0+
- Xcode 14.0+
- Swift 5.7+

### Building
```bash
# Debug build (recommended for development)
open AudioKeeper.xcodeproj
# Press Cmd + R in Xcode

# Release build
cd Scripts
./build_release.sh
```

### Installation
```bash
# Install to Applications
./install_app.sh
```

### Distribution
```bash
# Create DMG installer
cd Scripts
./create_dmg.sh
```

## 📚 Documentation

- [📖 English Documentation](README.md)
- [📖 Russian Documentation](README_RU.md)
- [🚀 Quick Start Guide](Documentation/QUICK_START.md)
- [📦 Distribution Guide](Documentation/FINAL_SETUP_GUIDE.md)
- [🏗️ Project Structure](Documentation/PROJECT_STRUCTURE.md)
- [⚙️ Menu Bar Setup](Documentation/MENUBAR_SETUP.md)

## 🔧 How It Works

AudioKeeper uses CoreAudio APIs to:
- Monitor system audio device changes in real-time
- Detect when new devices are connected/disconnected
- Automatically restore your preferred devices
- Maintain settings persistently using UserDefaults

The app runs as a menu bar accessory with no Dock icon, providing a clean and unobtrusive experience.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with SwiftUI and CoreAudio
- Inspired by the need for better audio device management on macOS
- Thanks to the macOS developer community

## 📞 Support

- 🐛 **Bug Reports**: [Open an issue](https://github.com/rekruizer/AudioKeeper/issues)
- 💡 **Feature Requests**: [Open an issue](https://github.com/rekruizer/AudioKeeper/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/rekruizer/AudioKeeper/discussions)

---

<div align="center">

**Made with ❤️ for macOS audio enthusiasts**

[⭐ Star this repo](https://github.com/rekruizer/AudioKeeper) • [🐛 Report Bug](https://github.com/rekruizer/AudioKeeper/issues) • [💡 Request Feature](https://github.com/rekruizer/AudioKeeper/issues)

</div>
