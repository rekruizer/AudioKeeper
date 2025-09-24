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
1. **Download** the latest release
2. **Install** AudioKeeper.app to Applications
3. **Launch** and find the headphone icon in your menu bar
4. **Configure** your preferred input/output devices
5. **Enjoy** automatic audio device management!

### For Developers
```bash
# Clone the repository
git clone https://github.com/yourusername/AudioKeeper.git
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
├── AudioKeeper/              # Main application
│   ├── Sources/             # Swift source code
│   │   ├── App/            # Main app files
│   │   ├── Audio/          # Audio device management
│   │   └── Models/         # Data models
│   ├── Assets.xcassets/     # App icons and resources
│   ├── Scripts/            # Build and distribution scripts
│   ├── Documentation/      # Detailed documentation
│   ├── README.md          # English documentation
│   └── README_RU.md       # Russian documentation
├── AudioKeeper.xcodeproj   # Xcode project file
├── LICENSE                 # MIT License
└── README.md              # This file
```

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
cd AudioKeeper/Scripts
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
cd AudioKeeper/Scripts
./create_dmg.sh
```

## 📚 Documentation

- [📖 English Documentation](AudioKeeper/README.md)
- [📖 Russian Documentation](AudioKeeper/README_RU.md)
- [🚀 Quick Start Guide](AudioKeeper/Documentation/QUICK_START.md)
- [📦 Distribution Guide](AudioKeeper/Documentation/FINAL_SETUP_GUIDE.md)
- [🏗️ Project Structure](AudioKeeper/Documentation/PROJECT_STRUCTURE.md)
- [⚙️ Menu Bar Setup](AudioKeeper/Documentation/MENUBAR_SETUP.md)

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

- 🐛 **Bug Reports**: [Open an issue](https://github.com/yourusername/AudioKeeper/issues)
- 💡 **Feature Requests**: [Open an issue](https://github.com/yourusername/AudioKeeper/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/yourusername/AudioKeeper/discussions)

---

<div align="center">

**Made with ❤️ for macOS audio enthusiasts**

[⭐ Star this repo](https://github.com/yourusername/AudioKeeper) • [🐛 Report Bug](https://github.com/yourusername/AudioKeeper/issues) • [💡 Request Feature](https://github.com/yourusername/AudioKeeper/issues)

</div>
