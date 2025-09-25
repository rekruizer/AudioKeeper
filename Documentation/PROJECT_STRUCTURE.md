# AudioKeeper - Project Structure

This document describes the professional project structure for AudioKeeper.

## Root Level Structure

```
AudioKeeper/                          # Project root
├── README.md                        # Main project README (English)
├── LICENSE                          # MIT License
├── .gitignore                       # Git ignore rules
├── AudioKeeper.xcodeproj/           # Xcode project file
└── AudioKeeper/                     # Application source directory
```

## Application Directory Structure

```
AudioKeeper/                         # Application source
├── README.md                        # Application README (English)
├── README_RU.md                     # Application README (Russian)
├── Info.plist                       # App configuration
├── Sources/                         # Swift source code
│   ├── App/                        # Main application files
│   │   ├── AudioKeeperApp.swift    # SwiftUI app entry point
│   │   ├── AppDelegate.swift       # App state and menu UI
│   │   └── UpdateManager.swift     # GitHub-based automatic updates
│   ├── Audio/                      # Audio device management
│   │   ├── AudioDeviceMonitor.swift # CoreAudio monitoring
│   │   └── AudioSwitcher.swift     # Device control
│   └── Models/                     # Data models
│       └── Preferences.swift       # User settings
├── Assets.xcassets/                # App resources
│   ├── AppIcon.appiconset/         # App icons
│   └── AccentColor.colorset/       # Accent color
├── Documentation/                  # Project documentation
│   ├── FINAL_SETUP_GUIDE.md       # Distribution setup
│   ├── QUICK_START.md             # Quick start guide
│   ├── DISTRIBUTION_README.md     # Distribution guide
│   └── PROJECT_STRUCTURE.md       # This file
└── Scripts/                       # Build and utility scripts
    ├── build_release.sh           # Release build script
    ├── create_dmg.sh             # DMG creation script
    ├── generate_icons.sh         # Icon generation
    ├── setup_distribution.sh     # Distribution setup
    ├── create_simple_icon.py     # Icon creation utility
    └── icon.svg                  # Source icon file
```

## File Responsibilities

### Core Application Files

- **AudioKeeperApp.swift**: Main SwiftUI app with MenuBarExtra
- **AppDelegate.swift**: App state management, menu UI, device switching logic, and update UI integration
- **UpdateManager.swift**: GitHub-based automatic update system with weekly checks and one-click installation
- **AudioDeviceMonitor.swift**: CoreAudio property listeners for device changes
- **AudioSwitcher.swift**: CoreAudio device enumeration and control
- **Preferences.swift**: UserDefaults persistence for app settings including update preferences

### Configuration Files

- **Info.plist**: App metadata, permissions, and system requirements
- **Assets.xcassets**: App icons and visual resources
- **Contents.json**: Asset catalog configuration

### Documentation Files

- **README.md**: Main project documentation (English)
- **README_RU.md**: Russian documentation
- **FINAL_SETUP_GUIDE.md**: Distribution setup instructions
- **QUICK_START.md**: Quick start guide
- **DISTRIBUTION_README.md**: Detailed distribution guide

### Build Scripts

- **build_release.sh**: Automated release build process
- **create_dmg.sh**: DMG installer creation
- **generate_icons.sh**: Icon generation from SVG
- **setup_distribution.sh**: Initial distribution setup

## Professional Standards

This structure follows macOS development best practices:

1. **Separation of Concerns**: Clear separation between UI, business logic, and data
2. **Modular Design**: Each component has a single responsibility
3. **Documentation**: Comprehensive documentation in multiple languages
4. **Build Automation**: Scripts for common development tasks
5. **Version Control**: Proper .gitignore and file organization
6. **Distribution Ready**: All necessary files for app distribution

## Development Workflow

1. **Source Code**: Modify files in `Sources/` directory
2. **Resources**: Add icons and assets to `Assets.xcassets`
3. **Configuration**: Update `Info.plist` for app metadata
4. **Build**: Use `Scripts/build_release.sh` for distribution builds
5. **Documentation**: Update relevant files in `Documentation/`

## Distribution Workflow

1. **Configure**: Update Bundle Identifier in `Info.plist`
2. **Sign**: Set up code signing in Xcode
3. **Build**: Run `Scripts/build_release.sh`
4. **Package**: Run `Scripts/create_dmg.sh`
5. **Test**: Verify on clean macOS installation

This structure ensures maintainability, scalability, and professional distribution standards.
