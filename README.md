<span><img src="Assets.xcassets/AppIcon.appiconset/55321 1.png" alt="AudioKeeper" width="64" height="64" style="vertical-align: middle; margin-right: 15px;"> <h1 style="display: inline; margin: 0; vertical-align: middle;">AudioKeeper</h1></span>

[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://developer.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**Keeps your preferred audio devices** - no more manual switching when you connect/disconnect headphones, speakers, or microphones. Everything automatic and simple!

[![Download](https://img.shields.io/badge/Download-Latest%20Release-blue?style=for-the-badge&logo=github)](https://github.com/rekruizer/AudioKeeper/releases/latest)

<img src="images/menu-screenshot.png" alt="AudioKeeper Menu Interface" width="500">


## 🚀 Quick Start

1. **Download** → **Install** → **Launch**
2. Find the 🎧 icon in your menu bar
3. Select your preferred devices and enjoy!


## ✨ Features
Everything is simple!
- 🔄 **Automatic Device Management** - Choose your devices, that will be kept as output/input devices. Even if something changes.
- 💾 **Persistent Settings** - Remembers your preferences between sessions
- ⚡ **Real-time Monitoring** - Instant response to device connections
- 🎧 **Minimalistic** - Clean interface, no Dock clutter


## 📦 Installation

### Option 1: Homebrew (Recommended)
```bash
# Add the AudioKeeper tap
brew tap rekruizer/audiokeeper https://github.com/rekruizer/AudioKeeper

# Install AudioKeeper
brew install --cask audiokeeper
```

> **Note:** Homebrew installation automatically handles macOS security warnings. The app will work immediately without any manual quarantine removal!

<details>
<summary><b>About Code Signing & Notarization</b></summary>

AudioKeeper is not notarized by Apple. Notarization requires sending binaries to Apple for approval, which involves:
- Annual Apple Developer Program fees ($99/year)
- Compliance with Apple's specific build requirements
- Ongoing maintenance overhead for a free, open-source project

**By using AudioKeeper, you acknowledge that it's not notarized.** The app is completely open-source, and you can review the code yourself. The Homebrew installation script automatically removes the `com.apple.quarantine` attribute, so the app works out of the box without security warnings.

For transparency: this approach is used by other open-source macOS apps like [AeroSpace](https://github.com/nikitabobko/AeroSpace).
</details>

### Option 2: Manual Download
1. Download from [GitHub Releases](https://github.com/rekruizer/AudioKeeper/releases)
2. **If DMG won't open**: Right-click DMG → "Open" → "Open" (bypasses security warning)
3. Open DMG and drag AudioKeeper.app to Applications
4. **First launch**: Right-click AudioKeeper.app → "Open" → "Open" (required for unsigned apps)
5. **Optional - Remove quarantine attribute** to avoid future warnings:
   ```bash
   xattr -d com.apple.quarantine /Applications/AudioKeeper.app
   ```

> **Security Note:** macOS shows warnings for unsigned apps. This is normal and safe. AudioKeeper is open-source - you can review the code yourself.


## 🛠️ Development

```bash
# Clone and build
git clone https://github.com/rekruizer/AudioKeeper.git
cd AudioKeeper
open AudioKeeper.xcodeproj
# Press Cmd + R in Xcode
```

**Requirements:** macOS 13.0+, Xcode 14.0+, Swift 5.7+


## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request






# 💖 Support the Project

Hey, Your support would honestly brighten my day! 🙌

There's something really nice about knowing that the things I build are actually helping people. Every contribution is like a little reminder that this work matters to someone.

*Your support helps me continue building!* 💙
- 🚀 Continue development and new features
- 🐛 Fix bugs and improve stability
- 📚 Create better documentation
- ⚡ Keep the project maintained


[![PayPal](https://img.shields.io/badge/Donate-PayPal-0070BA?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/rekruizer)

### ₿ Crypto Donations

**Bitcoin:**
```
bc1q9xj5p220tqgdn7gxjhuc9uk39xyl59vj0qs89f
```
**Ethereum:**
```
0x89D36cA00D690f294ebEaB81276062BCd9a5E8D0
```
**USDT:**
```
0x89D36cA00D690f294ebEaB81276062BCd9a5E8D0
```



### 📄 License

MIT License - see [LICENSE](LICENSE) for details.

### 🆘 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/rekruizer/AudioKeeper/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/rekruizer/AudioKeeper/discussions)