import Foundation
import ServiceManagement
import os.log

final class LaunchAtLoginHelper {
	static let shared = LaunchAtLoginHelper()

	private let service = SMAppService.mainApp

	private init() {}

	/// Check if launch at login is currently enabled
	/// - Returns: true if the app is registered to launch at login
	func isEnabled() -> Bool {
		return service.status == .enabled
	}

	/// Enable or disable launch at login
	/// - Parameter enabled: true to enable, false to disable
	/// - Returns: true if the operation was successful, false otherwise
	func setEnabled(_ enabled: Bool) -> Bool {
		do {
			if enabled {
				// Already enabled, nothing to do
				if service.status == .enabled {
					return true
				}
				// Register the app to launch at login
				try service.register()
				return true
			} else {
				// Already disabled, nothing to do
				if service.status == .notRegistered {
					return true
				}
				// Unregister from launch at login
				try service.unregister()
				return true
			}
		} catch {
			Logger.preferences.error("Failed to \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)")
			return false
		}
	}
}
