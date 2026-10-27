import Foundation

@MainActor
private final class FakeAudioSwitcher: AudioDeviceSwitching {
	var devices: [AudioDeviceInfo] = []
	var defaults: [AudioRole: String] = [:]
	var calls: [(String, AudioRole)] = []
	var delay: UInt64 = 0

	func listDevices() -> [AudioDeviceInfo] { devices }
	func getDefaultDeviceUID(role: AudioRole) -> String? { defaults[role] }
	func setDefaultDevice(uid: String, role: AudioRole) async -> Result<Void, AudioSwitcherError> {
		if delay > 0 {
			do { try await Task.sleep(nanoseconds: delay) }
			catch { return .failure(.cancelled) }
		}
		guard !Task.isCancelled else { return .failure(.cancelled) }
		calls.append((uid, role))
		defaults[role] = uid
		return .success(())
	}
}

nonisolated private final class StubURLProtocol: URLProtocol, @unchecked Sendable {
	nonisolated(unsafe) static var statusCode = 200
	override class func canInit(with request: URLRequest) -> Bool { true }
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
	override func startLoading() {
		let body = Data(#"{"tag_name":"v99.0.0","body":null,"published_at":"2026-10-27T10:00:00Z","assets":[{"name":"AudioKeeper-v99.0.0.dmg","browser_download_url":"https://github.com/rekruizer/AudioKeeper/releases/download/v99.0.0/AudioKeeper-v99.0.0.dmg","size":100}]}"#.utf8)
		let response = HTTPURLResponse(url: request.url!, statusCode: Self.statusCode, httpVersion: nil, headerFields: nil)!
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: body)
		client?.urlProtocolDidFinishLoading(self)
	}
	override func stopLoading() {}
}

@main
@MainActor
struct RegressionTests {
	static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
		precondition(condition(), message)
	}

	static func eventually(_ condition: () -> Bool) async throws {
		for _ in 0..<200 {
			if condition() { return }
			try await Task.sleep(nanoseconds: 10_000_000)
		}
		preconditionFailure("Timed out waiting for asynchronous operation")
	}

	static func main() async throws {
		let suite = "AudioKeeper.RegressionTests.\(UUID().uuidString)"
		let defaults = UserDefaults(suiteName: suite)!
		defer { defaults.removePersistentDomain(forName: suite) }
		let store = PreferencesStore(defaults: defaults)
		let key = "AudioKeeper.Preferences"

		// Existing settings must survive new fields and renamed devices.
		defaults.set(Data(#"{"isActive":false,"preferredOutputUID":"headset"}"#.utf8), forKey: key)
		var preferences = store.load(currentInputUID: nil, currentOutputUID: nil)
		expect(!preferences.isActive && preferences.preferredOutputUID == "headset", "Lost legacy preferences")
		expect(preferences.updateCheckFrequency == 604800 && !preferences.launchAtLogin, "Wrong migration defaults")
		defaults.set(Data(#"{"isActive":true,"updateCheckFrequency":-1}"#.utf8), forKey: key)
		expect(store.load(currentInputUID: nil, currentOutputUID: nil).updateCheckFrequency == 604800, "Invalid frequency accepted")
		preferences = Preferences(isActive: true)
		store.save(preferences)
		var checked = preferences
		checked.lastUpdateCheck = Date()
		store.save(checked)
		preferences.isActive = false
		store.save(preferences)
		let merged = store.load(currentInputUID: nil, currentOutputUID: nil)
		expect(merged.lastUpdateCheck == checked.lastUpdateCheck && !merged.isActive, "Stale snapshot overwrote update date")
		print("PASS: preferences migration, validation and stale-date preservation")

		let duplex = AudioDeviceInfo(uid: "headset", name: "USB Headset", isInput: true, isOutput: true, isAvailable: true)
		let other = AudioDeviceInfo(uid: "speakers", name: "Speakers", isInput: false, isOutput: true, isAvailable: true)
		defaults.removeObject(forKey: key)
		store.save(Preferences(isActive: true, preferredInputUID: duplex.uid, preferredOutputUID: duplex.uid))
		let audio = FakeAudioSwitcher()
		audio.devices = [duplex, other]
		let state = AppState(store: store, switcher: audio, monitor: nil)
		defer { state.cleanup() }
		try await eventually { audio.calls.count == 2 }
		expect(state.preferences.preferredInputName == duplex.name && state.preferences.preferredOutputName == duplex.name, "Names not learned on startup")
		expect(audio.defaults[.input] == duplex.uid && audio.defaults[.output] == duplex.uid, "Preferences not restored on startup")

		audio.devices = [other]
		audio.defaults = [.output: other.uid]
		state.deviceListDidChange()
		let offline = state.getAllDevicesForDisplay().filter { $0.uid == duplex.uid }
		expect(offline.count == 1 && offline[0].isInput && offline[0].isOutput, "Offline duplex device missing from a picker")
		expect(!offline[0].isAvailable && offline[0].name == duplex.name, "Offline name lost")
		let restarted = AppState(store: store, switcher: audio, monitor: nil)
		expect(restarted.getAllDevicesForDisplay().contains(where: { $0.name == duplex.name && !$0.isAvailable }), "Offline name lost after restart")
		restarted.cleanup()
		audio.calls.removeAll()
		try await Task.sleep(nanoseconds: 150_000_000)
		expect(audio.calls.isEmpty, "Attempted to select an unavailable device")

		audio.devices = [AudioDeviceInfo(uid: duplex.uid, name: "Renamed Headset", isInput: true, isOutput: true, isAvailable: true), other]
		state.deviceListDidChange()
		try await eventually { audio.defaults[.input] == duplex.uid && audio.defaults[.output] == duplex.uid }
		expect(state.preferences.preferredOutputName == "Renamed Headset", "Device rename not remembered")
		print("PASS: startup/reconnect restoration, offline duplex devices, persisted names and rename")

		audio.calls.removeAll()
		audio.defaults[.output] = other.uid
		for _ in 0..<10 { state.defaultDeviceDidChange(role: .output) }
		try await eventually { audio.calls.count == 1 }
		expect(audio.calls[0].0 == duplex.uid, "Event burst restored the wrong device")
		audio.calls.removeAll()
		audio.defaults[.output] = other.uid
		state.defaultDeviceDidChange(role: .output)
		state.setActive(false)
		try await Task.sleep(nanoseconds: 150_000_000)
		expect(audio.calls.isEmpty, "Switched after Active was disabled")
		state.setActive(true)
		state.setPreferredOutput(uid: nil)
		try await Task.sleep(nanoseconds: 150_000_000)
		expect(audio.calls.isEmpty && state.preferences.preferredOutputName == nil, "System Default did not cancel pending switch")
		state.setPreferredOutput(uid: "unseen-device")
		expect(state.preferences.preferredOutputName == nil, "New UID inherited the old device name")

		audio.delay = 300_000_000
		state.setPreferredOutput(uid: duplex.uid)
		try await Task.sleep(nanoseconds: 150_000_000)
		state.setPreferredOutput(uid: other.uid)
		try await Task.sleep(nanoseconds: 450_000_000)
		expect(audio.calls.isEmpty && audio.defaults[.output] == other.uid, "Cancelled retry switched to a stale selection")
		print("PASS: event coalescing, pause, System Default and cancellation during a suspended switch")

		expect(UpdateManager.isVersionNewer("1.10.0", than: "1.9.9"), "Numeric version comparison failed")
		expect(!UpdateManager.isVersionNewer("1.2.2", than: "1.2.2.0"), "Equivalent versions differ")
		for invalid in ["1..3", "1.2-beta", "v1.2.3", "", "99999999999999999999999999"] {
			expect(!UpdateManager.isVersionNewer(invalid, than: "1.0"), "Malformed version accepted")
		}
		for invalid in ["http://github.com/rekruizer/AudioKeeper/releases/download/v1/a.dmg", "https://evil.example/a.dmg", "https://github.com/other/AudioKeeper/releases/download/v1/a.dmg", "https://github.com/rekruizer/AudioKeeper/releases/download/v1/a.zip", "https://github.com/rekruizer/AudioKeeper/releases/download/../a.dmg", "https://github.com/rekruizer/AudioKeeper/releases/download/v1/a.dmg?redirect=other"] {
			do { _ = try UpdateManager.validatedDownloadURL(invalid); preconditionFailure("Untrusted URL accepted") }
			catch UpdateError.invalidURL {}
		}
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [StubURLProtocol.self]
		let session = URLSession(configuration: configuration)
		defer { session.invalidateAndCancel() }
		let updater = UpdateManager(session: session, preferencesStore: store)
		StubURLProtocol.statusCode = 403
		updater.checkForUpdates()
		try await eventually { !updater.isCheckingForUpdates }
		expect(updater.lastError?.contains("403") == true, "HTTP errors not reported")
		StubURLProtocol.statusCode = 200
		updater.checkForUpdates()
		try await eventually { !updater.isCheckingForUpdates }
		expect(updater.updateAvailable?.version == "99.0.0" && updater.lastError == nil, "Release JSON/nullable body rejected")
		expect(updater.lastCheckedDate != nil, "Successful check date not saved")
		print("PASS: version/URL validation and update checks with mocked HTTP; no network or real audio changes")
	}
}
