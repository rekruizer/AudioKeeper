import SwiftUI

@main
struct AudioKeeperApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		MenuBarExtra("AudioKeeper", systemImage: "headphones") {
			AppMenuView()
				.environmentObject(appDelegate.appState)
				.environmentObject(appDelegate.updateManager)
		}
	}
}
