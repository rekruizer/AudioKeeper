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
		if let data = try? JSONEncoder().encode(prefs) {
			defaults.set(data, forKey: key)
		}
	}
}
