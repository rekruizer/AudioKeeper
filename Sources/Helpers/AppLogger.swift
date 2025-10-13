import os.log
import Foundation

/// Centralized logging system for AudioKeeper
/// Uses Apple's unified logging system (OSLog) for proper debug and release builds
extension Logger {
	/// Logger for audio device operations (monitoring, switching, listing)
	static let audio = Logger(subsystem: Bundle.main.bundleIdentifier ?? "denisyuce.AudioKeeper", category: "audio")

	/// Logger for update checking and installation
	static let updates = Logger(subsystem: Bundle.main.bundleIdentifier ?? "denisyuce.AudioKeeper", category: "updates")

	/// Logger for preferences and settings management
	static let preferences = Logger(subsystem: Bundle.main.bundleIdentifier ?? "denisyuce.AudioKeeper", category: "preferences")

	/// Logger for app lifecycle and system integration
	static let app = Logger(subsystem: Bundle.main.bundleIdentifier ?? "denisyuce.AudioKeeper", category: "app")
}

/// Log levels guide:
/// - .debug: Detailed diagnostic information for development
/// - .info: General informational messages
/// - .notice: Important but not critical events (default in Console.app)
/// - .error: Error conditions that need attention
/// - .fault: Critical errors that may cause crashes
