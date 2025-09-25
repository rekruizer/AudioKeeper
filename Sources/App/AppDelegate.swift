import Cocoa
import SwiftUI
import Combine

final class AppState: ObservableObject, AudioDeviceMonitorDelegate {
	@Published var preferences: Preferences
	@Published var devices: [AudioDeviceInfo] = []

	private let store = PreferencesStore.shared
	private let switcher = AudioSwitcher.shared
	private let monitor = AudioDeviceMonitor()

	init() {
		let currentIn = switcher.getDefaultDeviceUID(role: .input)
		let currentOut = switcher.getDefaultDeviceUID(role: .output)
		self.preferences = store.load(currentInputUID: currentIn, currentOutputUID: currentOut)
		self.devices = switcher.listDevices()
		monitor.delegate = self
		monitor.start()
	}

	func defaultDeviceDidChange(role: AudioRole) {
		// Simple logic: if app is active and has preference, restore it
		guard preferences.isActive else { return }
		
		// Small delay for stability
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			guard let self else { return }
			
			switch role {
			case .input:
				if let preferredUID = self.preferences.preferredInputUID,
				   let currentUID = self.switcher.getDefaultDeviceUID(role: .input),
				   currentUID != preferredUID {
					self.switcher.setDefaultDevice(uid: preferredUID, role: .input)
				}
			case .output:
				if let preferredUID = self.preferences.preferredOutputUID,
				   let currentUID = self.switcher.getDefaultDeviceUID(role: .output),
				   currentUID != preferredUID {
					self.switcher.setDefaultDevice(uid: preferredUID, role: .output)
				}
			}
		}
	}

	func deviceListDidChange() {
		// Refresh device list; this often precedes default change when a new device connects
		self.devices = switcher.listDevices()
	}

	func setActive(_ isActive: Bool) {
		preferences.isActive = isActive
		store.save(preferences)
		
		// Immediately set preferences when activated
		if isActive {
			if let inputUID = preferences.preferredInputUID {
				switcher.setDefaultDevice(uid: inputUID, role: .input)
			}
			if let outputUID = preferences.preferredOutputUID {
				switcher.setDefaultDevice(uid: outputUID, role: .output)
			}
		}
	}

	func setPreferredInput(uid: String?) {
		preferences.preferredInputUID = uid
		store.save(preferences)
		
		// Immediately switch device in system if app is active
		if preferences.isActive, let uid = uid {
			switcher.setDefaultDevice(uid: uid, role: .input)
		}
	}

	func setPreferredOutput(uid: String?) {
		preferences.preferredOutputUID = uid
		store.save(preferences)
		
		// Immediately switch device in system if app is active
		if preferences.isActive, let uid = uid {
			switcher.setDefaultDevice(uid: uid, role: .output)
		}
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	static let sharedState = AppState()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		// Ensure app is completely hidden (not in Dock, not in Command+Tab)
		NSApp.setActivationPolicy(.prohibited)
		
		// Initialize UpdateManager for automatic update checks
		_ = UpdateManager.shared
	}
}

struct AppMenuView: View {
	@ObservedObject var state = AppDelegate.sharedState
	@ObservedObject var updateManager = UpdateManager.shared
	@State private var showingUpdateDialog = false

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			// Activity toggle
			Toggle("Active", isOn: Binding(
				get: { state.preferences.isActive },
				set: { state.setActive($0) }
			))
			.padding(.horizontal, 12)
			.padding(.vertical, 4)

			Divider()

			// Input device selection
			VStack(alignment: .leading, spacing: 2) {
				Text("Input:")
					.font(.caption)
					.foregroundColor(.secondary)
					.padding(.horizontal, 12)
				
				Picker("Input Device", selection: Binding(
					get: { state.preferences.preferredInputUID ?? "" },
					set: { state.setPreferredInput(uid: $0.isEmpty ? nil : $0) }
				)) {
					Text("System Default").tag("")
					ForEach(state.devices.filter { $0.isInput }, id: \.uid) { device in
						Text(device.name).tag(device.uid)
					}
				}
				.pickerStyle(.menu)
				.padding(.horizontal, 12)
			}

			// Output device selection
			VStack(alignment: .leading, spacing: 2) {
				Text("Output:")
					.font(.caption)
					.foregroundColor(.secondary)
					.padding(.horizontal, 12)
				
				Picker("Output Device", selection: Binding(
					get: { state.preferences.preferredOutputUID ?? "" },
					set: { state.setPreferredOutput(uid: $0.isEmpty ? nil : $0) }
				)) {
					Text("System Default").tag("")
					ForEach(state.devices.filter { $0.isOutput }, id: \.uid) { device in
						Text(device.name).tag(device.uid)
					}
				}
				.pickerStyle(.menu)
				.padding(.horizontal, 12)
			}

			Divider()
			
			// Updates section
			VStack(alignment: .leading, spacing: 4) {
				if updateManager.isCheckingForUpdates {
					HStack {
						ProgressView()
							.scaleEffect(0.7)
						Text("Checking for updates...")
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.padding(.horizontal, 12)
				} else if let update = updateManager.updateAvailable {
					VStack(alignment: .leading, spacing: 4) {
						HStack {
							Image(systemName: "arrow.down.circle.fill")
								.foregroundColor(.blue)
							Text("Update available v\(update.version)")
								.font(.caption)
								.fontWeight(.medium)
						}
						.padding(.horizontal, 12)
						
						Button("Download and Install") {
							updateManager.downloadAndInstallUpdate()
						}
						.buttonStyle(.borderless)
						.padding(.horizontal, 12)
						.padding(.vertical, 2)
					}
				} else {
					Button("Check for Updates") {
						updateManager.checkForUpdates()
					}
					.buttonStyle(.borderless)
					.padding(.horizontal, 12)
					.padding(.vertical, 4)
				}
				
				if let lastChecked = updateManager.lastCheckedDate {
					Text("Last checked: \(formatDate(lastChecked))")
						.font(.caption2)
						.foregroundColor(.secondary)
						.padding(.horizontal, 12)
				}
			}
			
			Divider()
			
			Button("Quit") { 
				NSApp.terminate(nil) 
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 4)
		}
		.padding(.vertical, 8)
		.frame(minWidth: 200)
	}
	
	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}
