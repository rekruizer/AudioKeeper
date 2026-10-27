# AudioKeeper maintenance

## Compatibility

- Runtime deployment target stays macOS 13+. No new OS-only API is required.
- Development requires Xcode 26+ / Swift 6.2+ (Swift 6 language mode).
- Current development host: macOS 27.0.1; installed Xcode: 27.1.
- Compiler and fake-device tests are not evidence of Bluetooth, USB, wake or
  Gatekeeper behavior on every supported macOS version.

## Architecture

- `AppState` owns preferences and device selection on `MainActor`. It coalesces
  CoreAudio events and cancels stale input/output tasks independently. Startup,
  device-list changes and wake use the same reconciliation path.
- `AudioSwitcher` implements `AudioDeviceSwitching`. It reads/writes CoreAudio
  properties, checks device liveness, re-resolves device IDs on each attempt and
  waits asynchronously between attempts. Tests inject a fake, never change the
  machine's audio devices and never request permissions.
- `AudioDeviceMonitor` owns the CoreAudio listeners. `AppDelegate` owns the
  workspace wake observer and coordinates cleanup.
- `AppMenuView` contains the existing native menu UI. No custom glass rendering
  or new UI framework is needed to follow system menu styling.
- `PreferencesStore` preserves legacy settings and a newer saved update-check
  timestamp when an older AppState snapshot is written.
- `UpdateManager` uses async URLSession on MainActor, checks HTTP statuses and
  release download URLs, prevents duplicate downloads and never overwrites an
  existing download. Installation is still manual: open the DMG and drag the app.

## Checks

```bash
./Scripts/test.sh
xcodebuild -project AudioKeeper.xcodeproj -scheme AudioKeeper \
  -configuration Debug -destination 'generic/platform=macOS' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

If the active developer directory points at CommandLineTools, use the per-command
prefix `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. This does not
change the machine's global Xcode selection. If Xcode asks for license acceptance,
review/accept it yourself before building; automation must not accept it for you.

Regression tests cover preferences migration, offline duplex-device names,
reconnection, startup restoration, rename, coalescing, cancellation, version and
URL validation, and mocked successful/failed update checks. CI runs these and a
Debug app build for pushes to main and pull requests. Release CI also runs tests.

## Before releasing

1. Test on a Mac with the oldest supported macOS and on current macOS.
2. Select a USB or Bluetooth duplex device for both input and output; unplug it.
   Both menus should retain the name with `(×)`, including after restarting.
3. Reconnect it; verify both defaults are restored without needing another system
   default-change event. Repeat after sleep, dock reconnection and rapid switching.
4. Disable Active during a pending retry: no delayed switch should occur. Test
   System Default independently for input and output.
5. Test Launch at Login, including the System Settings approval flow. Verify the
   actual sandboxed app can download/open a DMG and display update errors.
   Also upgrade from the previous release with existing preferences: release
   signing now preserves sandbox entitlements, so test both the first container
   migration and a machine that already has a container from an Xcode build.
6. Commit reviewed changes and push a new, unused `vX.Y.Z` tag on that commit.
   CI stamps Info.plist from the tag; no manual version edit is needed for releases.
   The build validates the embedded version; packaging uses that embedded version.
   Do not move published tags or replace published DMGs: Homebrew pins their hash.
7. Check Actions, the published DMG, its embedded version and Homebrew hash.

## Remaining release/security work

Ad-hoc signing is not Developer ID signing or Apple notarization. Gatekeeper may
block the app; removing quarantine is not a security assessment. The optional
legacy Developer ID branch in build_release.sh still manipulates a temporary
keychain; modernizing it and adding notarization should be a separate, credential-
aware change. HTTPS/repository URL validation does not authenticate a downloaded
binary against a compromised release account. Consider notarized releases and a
signed updater (for example Sparkle) before automatic in-place installation.

## Suggested next features (not implemented)

1. Ordered fallback devices per role: headphones → dock → built-in audio.
2. Show actual system devices alongside preferred devices, and expose switching
   errors in the menu instead of requiring Console.app.
3. Pause keeping devices for 15/60 minutes and add a keyboard shortcut.
4. Show login approval status explicitly and refresh it whenever the menu opens.
5. Explain AirPods microphone/profile behavior rather than silently changing an
   input preference; validate on real hardware before adding transport-specific rules.
