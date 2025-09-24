# AudioKeeper

A professional macOS menu bar application that automatically maintains your preferred audio input/output devices.

## Quick Start

1. Open `AudioKeeper.xcodeproj` in Xcode
2. Build and run (`Cmd + R`)
3. Click the headphone icon in your menu bar to configure

## Features

- 🎧 **Menu Bar Integration** - Clean, professional interface
- 🔄 **Automatic Device Management** - Restores your preferred devices
- 💾 **Persistent Settings** - Remembers your preferences
- 🛡️ **System Respect** - Doesn't interfere with manual changes
- ⚡ **Real-time Monitoring** - Instant response to device changes

## Requirements

- macOS 13.0+
- Xcode 14.0+ (for development)

## Documentation

- [English README](AudioKeeper/README.md)
- [Russian README](AudioKeeper/README_RU.md)
- [Distribution Guide](AudioKeeper/Documentation/FINAL_SETUP_GUIDE.md)
- [Quick Start Guide](AudioKeeper/Documentation/QUICK_START.md)

## Project Structure

```
AudioKeeper/
├── AudioKeeper/              # Main application
│   ├── Sources/             # Swift source code
│   ├── Assets.xcassets/     # App icons and resources
│   ├── Scripts/            # Build and distribution scripts
│   ├── Documentation/      # Detailed documentation
│   ├── README.md          # English documentation
│   └── README_RU.md       # Russian documentation
└── AudioKeeper.xcodeproj   # Xcode project file
```

## Development

### Building
```bash
# Debug build (in Xcode)
Cmd + R

# Release build
cd AudioKeeper/Scripts
./build_release.sh
```

### Distribution
```bash
cd AudioKeeper/Scripts
./create_dmg.sh
```

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Made with ❤️ for macOS audio enthusiasts**
