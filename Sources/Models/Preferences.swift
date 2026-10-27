import Foundation

struct Preferences: Codable, Equatable {
	var isActive: Bool
	var preferredInputUID: String?
	var preferredInputName: String?
	var preferredOutputUID: String?
	var preferredOutputName: String?
	var lastUpdateCheck: Date?
	var updateCheckFrequency: TimeInterval = 604800 // 7 days in seconds
	var launchAtLogin: Bool = false

	init(isActive: Bool, preferredInputUID: String? = nil, preferredInputName: String? = nil,
	     preferredOutputUID: String? = nil, preferredOutputName: String? = nil,
	     lastUpdateCheck: Date? = nil, updateCheckFrequency: TimeInterval = 604800, launchAtLogin: Bool = false) {
		self.isActive = isActive
		self.preferredInputUID = preferredInputUID
		self.preferredInputName = preferredInputName
		self.preferredOutputUID = preferredOutputUID
		self.preferredOutputName = preferredOutputName
		self.lastUpdateCheck = lastUpdateCheck
		self.updateCheckFrequency = updateCheckFrequency
		self.launchAtLogin = launchAtLogin
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		isActive = try values.decode(Bool.self, forKey: .isActive)
		preferredInputUID = try values.decodeIfPresent(String.self, forKey: .preferredInputUID)
		preferredInputName = try values.decodeIfPresent(String.self, forKey: .preferredInputName)
		preferredOutputUID = try values.decodeIfPresent(String.self, forKey: .preferredOutputUID)
		preferredOutputName = try values.decodeIfPresent(String.self, forKey: .preferredOutputName)
		lastUpdateCheck = try values.decodeIfPresent(Date.self, forKey: .lastUpdateCheck)
		let frequency = try values.decodeIfPresent(TimeInterval.self, forKey: .updateCheckFrequency) ?? 604800
		updateCheckFrequency = frequency.isFinite && frequency > 0 ? frequency : 604800
		launchAtLogin = try values.decodeIfPresent(Bool.self, forKey: .launchAtLogin) ?? false
	}
}

final class PreferencesStore {
	static let shared = PreferencesStore()
	private let key = "AudioKeeper.Preferences"
	private let defaults: UserDefaults

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	func load(currentInputUID: String?, currentOutputUID: String?, currentInputName: String? = nil, currentOutputName: String? = nil) -> Preferences {
		if let data = defaults.data(forKey: key),
		   let prefs = try? JSONDecoder().decode(Preferences.self, from: data) {
			return prefs
		}
		return Preferences(
			isActive: true,
			preferredInputUID: currentInputUID,
			preferredInputName: currentInputName,
			preferredOutputUID: currentOutputUID,
			preferredOutputName: currentOutputName,
			lastUpdateCheck: nil,
			updateCheckFrequency: 604800
		)
	}

	func save(_ prefs: Preferences) {
		var merged = prefs
		// AppState can hold a snapshot from before the updater saved its check date.
		if let data = defaults.data(forKey: key),
		   let saved = try? JSONDecoder().decode(Preferences.self, from: data),
		   let lastCheck = saved.lastUpdateCheck,
		   lastCheck > (merged.lastUpdateCheck ?? .distantPast) {
			merged.lastUpdateCheck = lastCheck
		}
		if let data = try? JSONEncoder().encode(merged) {
			defaults.set(data, forKey: key)
		}
	}
}
