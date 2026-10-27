import Cocoa
import SwiftUI
import Combine
import OSLog

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	let appState = AppState()
	let updateManager = UpdateManager.shared

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Stay out of the Dock while allowing permission panels and notifications.
		NSApp.setActivationPolicy(.accessory)

		updateManager.checkForAutomaticUpdate()

		// Sync launch at login state with system
		appState.syncLaunchAtLogin()
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(workspaceDidWake), name: NSWorkspace.didWakeNotification, object: nil)
	}

	@objc private func workspaceDidWake() {
		appState.refreshDevices()
		appState.syncLaunchAtLogin()
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Clean up CoreAudio listeners before app terminates
		Logger.app.info("Application terminating, cleaning up resources")
		appState.cleanup()
		NSWorkspace.shared.notificationCenter.removeObserver(self)
	}
}
