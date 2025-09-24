# Menu Bar App Configuration

## Overview
AudioKeeper is configured as a menu bar-only application that doesn't appear in the Dock.

## Configuration Details

### Info.plist Settings
```xml
<key>LSUIElement</key>
<true/>
<key>LSBackgroundOnly</key>
<false/>
```

- **LSUIElement**: Hides the app from the Dock and prevents it from showing in the Command+Tab switcher
- **LSBackgroundOnly**: Set to false to allow the app to have a user interface (menu bar)

### AppDelegate Configuration
```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    // Ensure app is hidden from Dock
    NSApp.setActivationPolicy(.accessory)
}
```

- **setActivationPolicy(.accessory)**: Programmatically sets the app as a menu bar accessory

### SwiftUI App Structure
```swift
@main
struct AudioKeeperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("AudioKeeper", systemImage: "headphones") {
            AppMenuView()
        }
    }
}
```

- **MenuBarExtra**: SwiftUI's modern way to create menu bar apps
- **No WindowGroup**: Ensures no main window is created

## Behavior
- ✅ App appears only in menu bar
- ✅ No Dock icon
- ✅ No window when launched
- ✅ Accessible via Command+Tab (can be disabled if needed)
- ✅ Runs in background
- ✅ Persists across reboots (if added to Login Items)

## Testing
To verify the configuration:
1. Build and run the app
2. Check that no icon appears in Dock
3. Verify menu bar icon is present
4. Confirm app settings are accessible via menu bar

## Notes
- The app will still appear in Activity Monitor
- Users can quit via the menu bar menu
- App respects system preferences for menu bar visibility
