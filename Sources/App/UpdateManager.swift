import Foundation
import Combine
import AppKit
import UserNotifications
import OSLog

nonisolated struct GitHubRelease: Codable, Sendable {
	let tagName: String
	let body: String?
	let publishedAt: String
	let assets: [GitHubAsset]

	enum CodingKeys: String, CodingKey {
		case tagName = "tag_name"
		case body
		case publishedAt = "published_at"
		case assets
	}
}

nonisolated struct GitHubAsset: Codable, Sendable {
	let name: String
	let browserDownloadUrl: String
	let size: Int

	enum CodingKeys: String, CodingKey {
		case name
		case browserDownloadUrl = "browser_download_url"
		case size
	}
}

struct UpdateInfo {
	let version: String
	let releaseNotes: String
	let downloadUrl: String
	let publishedDate: Date
}

@MainActor
final class UpdateManager: ObservableObject {
	static let shared = UpdateManager()

	@Published private(set) var isCheckingForUpdates = false
	@Published private(set) var isUpToDate = false
	@Published private(set) var isDownloadingUpdate = false
	@Published private(set) var updateAvailable: UpdateInfo?
	@Published private(set) var lastCheckedDate: Date?
	@Published private(set) var lastError: String?

	private let preferencesStore: PreferencesStore
	private let session: URLSession

	convenience init() {
		self.init(session: .shared, preferencesStore: .shared)
	}

	init(session: URLSession, preferencesStore: PreferencesStore) {
		self.session = session
		self.preferencesStore = preferencesStore
		lastCheckedDate = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil).lastUpdateCheck
	}

	func checkForUpdates(completion: (@MainActor () -> Void)? = nil) {
		guard !isCheckingForUpdates else { return }
		isCheckingForUpdates = true
		isUpToDate = false
		lastError = nil

		Task {
			defer {
				isCheckingForUpdates = false
				completion?()
			}
			do {
				var request = URLRequest(url: URL(string: "https://api.github.com/repos/rekruizer/AudioKeeper/releases/latest")!)
				request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
				let (data, response) = try await session.data(for: request)
				try Self.validateResponse(response)
				let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
				let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
				updateAvailable = try processRelease(release, currentVersion: currentVersion)
				isUpToDate = updateAvailable == nil
				lastCheckedDate = Date()
				var preferences = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil)
				preferences.lastUpdateCheck = lastCheckedDate
				preferencesStore.save(preferences)
			} catch {
				lastError = error.localizedDescription
				Logger.updates.error("Error checking for updates: \(error.localizedDescription)")
			}
		}
	}

	func downloadAndInstallUpdate() {
		guard let update = updateAvailable, !isDownloadingUpdate else { return }
		isDownloadingUpdate = true
		lastError = nil

		Task {
			defer { isDownloadingUpdate = false }
			do {
				let localURL = try await downloadUpdate(from: update.downloadUrl)
				guard NSWorkspace.shared.open(localURL) else { throw UpdateError.installationFailed }
				showUpdateNotification()
			} catch {
				lastError = error.localizedDescription
				Logger.updates.error("Error downloading update: \(error.localizedDescription)")
			}
		}
	}

	func checkForAutomaticUpdate() {
		let preferences = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil)
		if Date().timeIntervalSince(preferences.lastUpdateCheck ?? .distantPast) >= preferences.updateCheckFrequency {
			checkForUpdates()
		}
	}

	func processRelease(_ release: GitHubRelease, currentVersion: String) throws -> UpdateInfo? {
		let version = release.tagName.hasPrefix("v") ? String(release.tagName.dropFirst()) : release.tagName
		guard Self.isVersionNewer(version, than: currentVersion) else { return nil }
		guard let asset = release.assets.first(where: { $0.name == "AudioKeeper-v\(version).dmg" }) else {
			throw UpdateError.downloadFailed
		}
		_ = try Self.validatedDownloadURL(asset.browserDownloadUrl)
		return UpdateInfo(version: version, releaseNotes: release.body ?? "", downloadUrl: asset.browserDownloadUrl,
		                  publishedDate: ISO8601DateFormatter().date(from: release.publishedAt) ?? Date())
	}

	static func isVersionNewer(_ version: String, than current: String) -> Bool {
		func components(_ value: String) -> [Int]? {
			let parts = value.split(separator: ".", omittingEmptySubsequences: false)
			guard !parts.isEmpty, parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy({ $0 >= "0" && $0 <= "9" }) }) else { return nil }
			let numbers = parts.compactMap { Int($0) }
			return numbers.count == parts.count ? numbers : nil
		}
		guard let lhs = components(version), let rhs = components(current) else { return false }
		for index in 0..<max(lhs.count, rhs.count) {
			let left = index < lhs.count ? lhs[index] : 0
			let right = index < rhs.count ? rhs[index] : 0
			if left != right { return left > right }
		}
		return false
	}

	static func validateResponse(_ response: URLResponse) throws {
		guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
			throw UpdateError.httpStatus((response as? HTTPURLResponse)?.statusCode ?? 0)
		}
	}

	static func validatedDownloadURL(_ value: String) throws -> URL {
		guard let url = URL(string: value), url.scheme == "https", url.host == "github.com",
		      url.user == nil, url.password == nil, url.port == nil,
		      url.query == nil, url.fragment == nil, url.standardized.path == url.path,
		      url.path.hasPrefix("/rekruizer/AudioKeeper/releases/download/"), url.pathExtension == "dmg" else {
			throw UpdateError.invalidURL
		}
		return url
	}

	private func downloadUpdate(from value: String) async throws -> URL {
		let url = try Self.validatedDownloadURL(value)
		let (temporaryURL, response) = try await session.download(from: url)
		defer { try? FileManager.default.removeItem(at: temporaryURL) }
		try Self.validateResponse(response)
		let downloads = try FileManager.default.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		// Never delete a user's existing download before a replacement succeeds.
		let directory = downloads.appendingPathComponent("AudioKeeper-Update-\(UUID().uuidString)", isDirectory: true)
		try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		let destination = directory.appendingPathComponent(url.lastPathComponent)
		do {
			try FileManager.default.moveItem(at: temporaryURL, to: destination)
			return destination
		} catch {
			try? FileManager.default.removeItem(at: directory)
			throw error
		}
	}

	private func showUpdateNotification() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
			if let error { Logger.updates.error("Notification authorization failed: \(error.localizedDescription)") }
			guard granted else { return }
			let content = UNMutableNotificationContent()
			content.title = "AudioKeeper - Update Ready"
			content.body = "New version downloaded. Install it by dragging the app to the Applications folder."
			content.sound = .default
			UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: "update_ready", content: content, trigger: nil)) { error in
				if let error { Logger.updates.error("Error showing notification: \(error.localizedDescription)") }
			}
		}
	}
}

enum UpdateError: LocalizedError {
	case invalidURL
	case downloadFailed
	case installationFailed
	case httpStatus(Int)

	var errorDescription: String? {
		switch self {
		case .invalidURL: return "Invalid URL for update download"
		case .downloadFailed: return "No compatible AudioKeeper DMG found in the release"
		case .installationFailed: return "Could not open the downloaded DMG"
		case .httpStatus(let code): return "GitHub request failed (HTTP \(code))"
		}
	}
}
