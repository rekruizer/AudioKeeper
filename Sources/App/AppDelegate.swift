import Cocoa
import SwiftUI
import Combine
import OSLog

final class AppState: ObservableObject, AudioDeviceMonitorDelegate {
	@Published var preferences: Preferences
	@Published var devices: [AudioDeviceInfo] = []

	private let store = PreferencesStore.shared
	private let switcher = AudioSwitcher.shared
	private let monitor = AudioDeviceMonitor()

	init() {
		let currentDevices = switcher.listDevices()
		self.devices = currentDevices
		let currentIn = switcher.getDefaultDeviceUID(role: .input)
		let currentOut = switcher.getDefaultDeviceUID(role: .output)
		let currentInName = currentDevices.first(where: { $0.uid == currentIn })?.name
		let currentOutName = currentDevices.first(where: { $0.uid == currentOut })?.name
		self.preferences = store.load(
			currentInputUID: currentIn,
			currentOutputUID: currentOut,
			currentInputName: currentInName,
			currentOutputName: currentOutName
		)
		populateMissingPreferredDeviceNames()
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
					_ = self.switcher.setDefaultDevice(uid: preferredUID, role: .input)
				}
			case .output:
				if let preferredUID = self.preferences.preferredOutputUID,
				   let currentUID = self.switcher.getDefaultDeviceUID(role: .output),
				   currentUID != preferredUID {
					_ = self.switcher.setDefaultDevice(uid: preferredUID, role: .output)
				}
			}
		}
	}

	func deviceListDidChange() {
		// Refresh device list; this often precedes default change when a new device connects
		self.devices = switcher.listDevices()
		populateMissingPreferredDeviceNames()
	}

	func setActive(_ isActive: Bool) {
		preferences.isActive = isActive
		store.save(preferences)

		// Immediately set preferences when activated
		if isActive {
			if let inputUID = preferences.preferredInputUID {
				_ = switcher.setDefaultDevice(uid: inputUID, role: .input)
			}
			if let outputUID = preferences.preferredOutputUID {
				_ = switcher.setDefaultDevice(uid: outputUID, role: .output)
			}
		}
	}

	func setPreferredInput(uid: String?) {
		preferences.preferredInputUID = uid
		preferences.preferredInputName = resolveDeviceName(for: uid, role: .input)
		store.save(preferences)

		// Immediately switch device in system if app is active
		if preferences.isActive, let uid = uid {
			_ = switcher.setDefaultDevice(uid: uid, role: .input)
		}
	}

	func setPreferredOutput(uid: String?) {
		preferences.preferredOutputUID = uid
		preferences.preferredOutputName = resolveDeviceName(for: uid, role: .output)
		store.save(preferences)

		// Immediately switch device in system if app is active
		if preferences.isActive, let uid = uid {
			_ = switcher.setDefaultDevice(uid: uid, role: .output)
		}
	}

	func setLaunchAtLogin(_ enabled: Bool) {
		// Try to set in system
		_ = LaunchAtLoginHelper.shared.setEnabled(enabled)

		// Only save the actual state (what really happened)
		let actualState = LaunchAtLoginHelper.shared.isEnabled()
		preferences.launchAtLogin = actualState
		store.save(preferences)
	}

	func refreshDevices() {
		self.devices = switcher.listDevices()
		populateMissingPreferredDeviceNames()
	}

	func cleanup() {
		// Stop monitoring to remove CoreAudio listeners
		monitor.stop()
		Logger.app.info("AppState cleanup completed")
	}

	/// Returns all devices including unavailable ones that are currently selected
	func getAllDevicesForDisplay() -> [AudioDeviceInfo] {
		var allDevices = devices

		// Add unavailable but selected input device if not in list
		if let inputUID = preferences.preferredInputUID,
		   !allDevices.contains(where: { $0.uid == inputUID }) {
			// Create placeholder for unavailable device
			let unavailableDevice = AudioDeviceInfo(
				uid: inputUID,
				name: preferences.preferredInputName ?? "Unknown Device",
				isInput: true,
				isOutput: false,
				isAvailable: false
			)
			allDevices.append(unavailableDevice)
		}

		// Add unavailable but selected output device if not in list
		if let outputUID = preferences.preferredOutputUID,
		   !allDevices.contains(where: { $0.uid == outputUID }) {
			// Create placeholder for unavailable device
			let unavailableDevice = AudioDeviceInfo(
				uid: outputUID,
				name: preferences.preferredOutputName ?? "Unknown Device",
				isInput: false,
				isOutput: true,
				isAvailable: false
			)
			allDevices.append(unavailableDevice)
		}

		return allDevices
	}

	private func resolveDeviceName(for uid: String?, role: AudioRole) -> String? {
		guard let uid else { return nil }

		// Prefer current in-memory list
		if let name = devices.first(where: { $0.uid == uid })?.name {
			return name
		}

		// Fallback to stored name for this role if it matches the same UID
		switch role {
		case .input:
			if preferences.preferredInputUID == uid {
				return preferences.preferredInputName
			}
		case .output:
			if preferences.preferredOutputUID == uid {
				return preferences.preferredOutputName
			}
		}

		return nil
	}

	private func populateMissingPreferredDeviceNames() {
		var changed = false

		if let inputUID = preferences.preferredInputUID,
		   preferences.preferredInputName == nil,
		   let name = devices.first(where: { $0.uid == inputUID })?.name {
			preferences.preferredInputName = name
			changed = true
		}

		if let outputUID = preferences.preferredOutputUID,
		   preferences.preferredOutputName == nil,
		   let name = devices.first(where: { $0.uid == outputUID })?.name {
			preferences.preferredOutputName = name
			changed = true
		}

		if changed {
			store.save(preferences)
		}
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	let appState = AppState()
	let updateManager = UpdateManager.shared

	func applicationDidFinishLaunching(_ notification: Notification) {
		// Ensure app is completely hidden (not in Dock, not in Command+Tab)
		NSApp.setActivationPolicy(.prohibited)

		// Initialize UpdateManager for automatic update checks (already initialized above)

		// Sync launch at login state with system
		let systemState = LaunchAtLoginHelper.shared.isEnabled()
		if appState.preferences.launchAtLogin != systemState {
			appState.preferences.launchAtLogin = systemState
			PreferencesStore.shared.save(appState.preferences)
		}
	}

	func applicationWillTerminate(_ notification: Notification) {
		// Clean up CoreAudio listeners before app terminates
		Logger.app.info("Application terminating, cleaning up resources")
		appState.cleanup()
	}

	deinit {
		// Ensure cleanup even if applicationWillTerminate is not called
		appState.cleanup()
	}
}

struct AppMenuView: View {
	@EnvironmentObject var state: AppState
	@EnvironmentObject var updateManager: UpdateManager
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
					ForEach(state.getAllDevicesForDisplay().filter { $0.isInput }, id: \.uid) { device in
						if device.isAvailable {
							Text(device.name).tag(device.uid)
						} else {
							Text("\(device.name) (×)")
								.foregroundColor(.secondary)
								.tag(device.uid)
						}
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
					ForEach(state.getAllDevicesForDisplay().filter { $0.isOutput }, id: \.uid) { device in
						if device.isAvailable {
							Text(device.name).tag(device.uid)
						} else {
							Text("\(device.name) (×)")
								.foregroundColor(.secondary)
								.tag(device.uid)
						}
					}
				}
				.pickerStyle(.menu)
				.padding(.horizontal, 12)
			}

			// Refresh Devices button
			Button("Refresh Devices") {
				state.refreshDevices()
			}
			.buttonStyle(.borderless)
			.padding(.horizontal, 12)
			.padding(.vertical, 4)

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

				// Show error if present
				if let error = updateManager.lastError {
					Text(error)
						.font(.caption2)
						.foregroundColor(.red)
						.padding(.horizontal, 12)
						.fixedSize(horizontal: false, vertical: true)
				}

				if let lastChecked = updateManager.lastCheckedDate {
					Text("Last checked: \(formatDate(lastChecked))")
						.font(.caption2)
						.foregroundColor(.secondary)
						.padding(.horizontal, 12)
				}
			}
			
			Divider()

			Toggle("Launch at Login", isOn: Binding(
				get: { state.preferences.launchAtLogin },
				set: { state.setLaunchAtLogin($0) }
			))
			.padding(.horizontal, 12)
			.padding(.vertical, 4)

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
