# AudioKeeper

A macOS menu bar application that keeps your preferred audio input/output devices active. It automatically restores your selected devices when the system changes the default audio device (typically when new devices are connected).

## Features

- **Menu Bar Integration**: Clean icon in your menu bar with easy access to settings
- **Automatic Device Management**: Monitors system audio device changes and restores your preferences
- **User-Friendly Interface**: Simple toggle to enable/disable functionality and device selection
- **Persistent Settings**: Remembers your preferences between app launches
- **System Integration**: Respects manual changes made in System Preferences

## Requirements

- macOS 13.0 or later
- Audio input/output devices

## Installation

### From Source

1. Clone or download this repository
2. Open `AudioKeeper.xcodeproj` in Xcode
3. Build and run the project (`Cmd + R`)

### Distribution Build

For a production build:

```bash
cd Scripts
./build_release.sh
```

This will create `AudioKeeper.app` ready for distribution.

## Usage

1. **Launch the app** - You'll see a headphone icon in your menu bar
2. **Click the icon** to open the settings menu
3. **Enable the app** using the "Active" toggle
4. **Select your preferred devices** for input and output
5. **The app will automatically restore these devices** when the system changes them

## How It Works

AudioKeeper uses CoreAudio APIs to:
- Monitor system audio device changes
- Detect when new devices are connected
- Automatically restore your preferred devices
- Maintain your settings persistently

## Configuration

### Bundle Identifier
Before distribution, update the Bundle Identifier in `Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.audiokeeper</string>
```

### Code Signing
Configure code signing in Xcode:
1. Select the project in Xcode
2. Choose Target → AudioKeeper → Signing & Capabilities
3. Select your development team

## Building for Distribution

1. **Configure Bundle Identifier** (see above)
2. **Set up code signing** in Xcode
3. **Build release version**:
   ```bash
   ./Scripts/build_release.sh
   ```
4. **Create DMG installer** (optional):
   ```bash
   ./Scripts/create_dmg.sh
   ```

## Project Structure

```
AudioKeeper/
├── Sources/
│   ├── App/           # Main app files
│   ├── Audio/         # Audio device management
│   └── Models/        # Data models and preferences
├── Assets.xcassets/   # App icons and assets
├── Documentation/     # Documentation files
├── Scripts/          # Build and distribution scripts
└── Info.plist        # App configuration
```

## Development

### Key Components

- **AudioKeeperApp.swift**: Main SwiftUI app entry point
- **AppDelegate.swift**: App state management and menu interface
- **AudioDeviceMonitor.swift**: CoreAudio device change monitoring
- **AudioSwitcher.swift**: Audio device control and management
- **Preferences.swift**: User settings persistence

### Adding Features

The app is designed to be easily extensible:
- Add new audio device properties in `AudioSwitcher.swift`
- Extend the menu interface in `AppDelegate.swift`
- Add new preferences in `Preferences.swift`

## Troubleshooting

### Common Issues

1. **App doesn't switch devices**
   - Check that the app is active (toggle in menu)
   - Verify audio permissions in System Settings → Privacy & Security

2. **App doesn't start**
   - Ensure code signing is configured
   - Check Bundle Identifier is unique

3. **Icon not displaying**
   - Verify app icons are properly set in Xcode
   - Check Assets.xcassets configuration

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is available under the MIT License. See the LICENSE file for details.

## Support

For issues and questions:
- Check the troubleshooting section above
- Review the documentation in the `Documentation/` folder
- Open an issue on the project repository