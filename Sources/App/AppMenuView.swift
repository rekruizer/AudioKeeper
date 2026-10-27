import SwiftUI
import AppKit

struct AppMenuView: View {
	@EnvironmentObject var state: AppState
	@EnvironmentObject var updateManager: UpdateManager

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
					if updateManager.isUpToDate {
						Text("You're up to date")
							.font(.caption)
							.foregroundColor(.secondary)
							.padding(.horizontal, 12)
					}
					Button("Check for Updates") {
						updateManager.checkForUpdates(completion: showUpdateCheckResult)
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

	private func showUpdateCheckResult() {
		// Menu actions dismiss the menu, so manual checks need feedback outside it.
		let alert = NSAlert()
		if let error = updateManager.lastError {
			alert.alertStyle = .warning
			alert.messageText = "Couldn't Check for Updates"
			alert.informativeText = "\(error)\n\nCheck your connection and try again."
			alert.addButton(withTitle: "Try Again")
			alert.addButton(withTitle: "Cancel")
		} else if let update = updateManager.updateAvailable {
			alert.messageText = "Update Available"
			alert.informativeText = "AudioKeeper \(update.version) is available. Download the DMG, then drag AudioKeeper to Applications to install it."
			alert.addButton(withTitle: "Download Update")
			alert.addButton(withTitle: "Later")
		} else {
			let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
			alert.messageText = "You're Up to Date"
			alert.informativeText = "AudioKeeper \(version) is the latest available version."
			alert.addButton(withTitle: "OK")
		}
		if #available(macOS 14.0, *) {
			NSApp.activate()
		} else {
			NSApp.activate(ignoringOtherApps: true)
		}
		guard alert.runModal() == .alertFirstButtonReturn else { return }
		if updateManager.lastError != nil {
			updateManager.checkForUpdates(completion: showUpdateCheckResult)
		} else if updateManager.updateAvailable != nil {
			updateManager.downloadAndInstallUpdate()
		}
	}

	private func formatDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}
