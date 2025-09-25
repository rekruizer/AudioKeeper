import Foundation

struct Preferences: Codable, Equatable {
	var isActive: Bool
	var preferredInputUID: String?
	var preferredOutputUID: String?
}

final class PreferencesStore {
	static let shared = PreferencesStore()
	private let key = "AudioKeeper.Preferences"
	private let defaults: UserDefaults

	init(defaults: UserDefaults = .standard) {
		self.defaults = defaults
	}

	func load(currentInputUID: String?, currentOutputUID: String?) -> Preferences {
		if let data = defaults.data(forKey: key),
		   let prefs = try? JSONDecoder().decode(Preferences.self, from: data) {
			return prefs
		}
		return Preferences(isActive: true, preferredInputUID: currentInputUID, preferredOutputUID: currentOutputUID)
	}

	func save(_ prefs: Preferences) {
		if let data = try? JSONEncoder().encode(prefs) {
			defaults.set(data, forKey: key)
		}
	}
}
