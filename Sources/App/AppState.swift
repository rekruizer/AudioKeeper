import Foundation
import Combine
import OSLog

@MainActor
final class AppState: ObservableObject, AudioDeviceMonitorDelegate {
	@Published var preferences: Preferences
	@Published var devices: [AudioDeviceInfo]

	private let store: PreferencesStore
	private let switcher: any AudioDeviceSwitching
	private let monitor: AudioDeviceMonitor?
	private var switchingTasks: [AudioRole: Task<Void, Never>] = [:]

	convenience init() {
		self.init(store: .shared, switcher: AudioSwitcher.shared, monitor: AudioDeviceMonitor())
	}

	init(store: PreferencesStore, switcher: any AudioDeviceSwitching, monitor: AudioDeviceMonitor?) {
		self.store = store
		self.switcher = switcher
		self.monitor = monitor
		let currentDevices = switcher.listDevices()
		self.devices = currentDevices
		let currentIn = switcher.getDefaultDeviceUID(role: .input)
		let currentOut = switcher.getDefaultDeviceUID(role: .output)
		self.preferences = store.load(
			currentInputUID: currentIn,
			currentOutputUID: currentOut,
			currentInputName: currentDevices.first(where: { $0.uid == currentIn })?.name,
			currentOutputName: currentDevices.first(where: { $0.uid == currentOut })?.name
		)
		rememberPreferredDeviceNames()
		monitor?.delegate = self
		monitor?.start()
		reconcilePreferredDevices()
	}

	func defaultDeviceDidChange(role: AudioRole) {
		scheduleSwitch(role: role)
	}

	func deviceListDidChange() {
		refreshDevices()
	}

	func setActive(_ isActive: Bool) {
		preferences.isActive = isActive
		store.save(preferences)
		reconcilePreferredDevices()
	}

	func setPreferredInput(uid: String?) {
		let name = resolveDeviceName(for: uid, role: .input)
		preferences.preferredInputUID = uid
		preferences.preferredInputName = name
		store.save(preferences)
		scheduleSwitch(role: .input)
	}

	func setPreferredOutput(uid: String?) {
		let name = resolveDeviceName(for: uid, role: .output)
		preferences.preferredOutputUID = uid
		preferences.preferredOutputName = name
		store.save(preferences)
		scheduleSwitch(role: .output)
	}

	func setLaunchAtLogin(_ enabled: Bool) {
		_ = LaunchAtLoginHelper.shared.setEnabled(enabled)
		syncLaunchAtLogin()
	}

	func syncLaunchAtLogin() {
		let actualState = LaunchAtLoginHelper.shared.isEnabled()
		guard preferences.launchAtLogin != actualState else { return }
		preferences.launchAtLogin = actualState
		store.save(preferences)
	}

	func refreshDevices() {
		devices = switcher.listDevices()
		rememberPreferredDeviceNames()
		reconcilePreferredDevices()
	}

	private func reconcilePreferredDevices() {
		scheduleSwitch(role: .input)
		scheduleSwitch(role: .output)
	}

	private func scheduleSwitch(role: AudioRole) {
		switchingTasks[role]?.cancel()
		switchingTasks[role] = nil
		guard preferences.isActive else { return }

		// Coalesce CoreAudio event bursts and let Bluetooth/USB devices settle.
		switchingTasks[role] = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 100_000_000)
			} catch {
				return
			}
			guard let self, !Task.isCancelled, self.preferences.isActive else { return }
			let uid = role == .input ? self.preferences.preferredInputUID : self.preferences.preferredOutputUID
			guard let uid,
			      self.devices.contains(where: { $0.uid == uid && $0.isAvailable && (role == .input ? $0.isInput : $0.isOutput) }),
			      self.switcher.getDefaultDeviceUID(role: role) != uid else { return }
			if case .failure(let error) = await self.switcher.setDefaultDevice(uid: uid, role: role), !Task.isCancelled {
				Logger.audio.error("Unable to restore preferred device: \(error.description)")
			}
		}
	}

	func cleanup() {
		for task in switchingTasks.values { task.cancel() }
		switchingTasks.removeAll()
		monitor?.stop()
	}

	isolated deinit {
		cleanup()
	}

	/// A missing duplex device must remain visible in both pickers.
	func getAllDevicesForDisplay() -> [AudioDeviceInfo] {
		var allDevices = devices
		let selectedUIDs = Set([preferences.preferredInputUID, preferences.preferredOutputUID].compactMap { $0 })
		for uid in selectedUIDs.sorted() where !allDevices.contains(where: { $0.uid == uid }) {
			let isInput = preferences.preferredInputUID == uid
			let isOutput = preferences.preferredOutputUID == uid
			let name = (isInput ? preferences.preferredInputName : nil)
				?? (isOutput ? preferences.preferredOutputName : nil) ?? "Unknown Device"
			allDevices.append(AudioDeviceInfo(uid: uid, name: name, isInput: isInput, isOutput: isOutput, isAvailable: false))
		}
		return allDevices
	}

	private func resolveDeviceName(for uid: String?, role: AudioRole) -> String? {
		guard let uid else { return nil }
		if let name = devices.first(where: { $0.uid == uid })?.name { return name }
		switch role {
		case .input:
			return preferences.preferredInputUID == uid ? preferences.preferredInputName : nil
		case .output:
			return preferences.preferredOutputUID == uid ? preferences.preferredOutputName : nil
		}
	}

	private func rememberPreferredDeviceNames() {
		let inputName = resolveDeviceName(for: preferences.preferredInputUID, role: .input)
		let outputName = resolveDeviceName(for: preferences.preferredOutputUID, role: .output)
		guard preferences.preferredInputName != inputName || preferences.preferredOutputName != outputName else { return }
		preferences.preferredInputName = inputName
		preferences.preferredOutputName = outputName
		store.save(preferences)
	}
}
