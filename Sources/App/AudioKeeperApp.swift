import SwiftUI

@main
struct AudioKeeperApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@ObservedObject private var updateManager = UpdateManager.shared

	var body: some Scene {
		MenuBarExtra(updateManager.isCheckingForUpdates ? "AudioKeeper — Checking for updates…" : "AudioKeeper",
		             systemImage: updateManager.isCheckingForUpdates ? "arrow.triangle.2.circlepath" : "headphones") {
			AppMenuView()
				.environmentObject(appDelegate.appState)
				.environmentObject(updateManager)
		}
	}
}
