import Foundation
import Combine

// MARK: - Update Models
struct GitHubRelease: Codable {
	let tagName: String
	let name: String
	let body: String
	let publishedAt: String
	let assets: [GitHubAsset]
}

struct GitHubAsset: Codable {
	let name: String
	let browserDownloadUrl: String
	let size: Int
}

struct UpdateInfo {
	let version: String
	let releaseNotes: String
	let downloadUrl: String
	let publishedDate: Date
}

// MARK: - Update Manager
final class UpdateManager: ObservableObject {
	static let shared = UpdateManager()
	
	@Published var isCheckingForUpdates = false
	@Published var updateAvailable: UpdateInfo?
	@Published var lastCheckedDate: Date?
	
	private let preferencesStore = PreferencesStore.shared
	private let session = URLSession.shared
	private let githubAPIBaseURL = "https://api.github.com"
	private let repositoryOwner = "rekruizer" // GitHub repository owner
	private let repositoryName = "AudioKeeper" // GitHub repository name
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		// Load last check date from preferences
		lastCheckedDate = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil).lastUpdateCheck
		
		// Automatic check on launch if enough time has passed
		checkForAutomaticUpdate()
	}
	
	// MARK: - Public Methods
	
	func checkForUpdates() {
		guard !isCheckingForUpdates else { return }
		
		isCheckingForUpdates = true
		
		checkForUpdatesInternal { [weak self] result in
			DispatchQueue.main.async {
				self?.isCheckingForUpdates = false
				
				switch result {
				case .success(let updateInfo):
					self?.updateAvailable = updateInfo
					self?.lastCheckedDate = Date()
					self?.saveLastCheckDate()
				case .failure(let error):
					print("Error checking for updates: \(error.localizedDescription)")
				}
			}
		}
	}
	
	func downloadAndInstallUpdate() {
		guard let updateInfo = updateAvailable else { return }
		
		downloadUpdate(from: updateInfo.downloadUrl) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case .success(let localURL):
					self?.installUpdate(from: localURL)
				case .failure(let error):
					print("Error downloading update: \(error.localizedDescription)")
				}
			}
		}
	}
	
	// MARK: - Private Methods
	
	private func checkForAutomaticUpdate() {
		let preferences = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil)
		
		guard let lastCheck = preferences.lastUpdateCheck else {
			// First launch - check for updates
			checkForUpdates()
			return
		}
		
		let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
		if timeSinceLastCheck >= preferences.updateCheckFrequency {
			checkForUpdates()
		}
	}
	
	private func checkForUpdatesInternal(completion: @escaping (Result<UpdateInfo?, Error>) -> Void) {
		let urlString = "\(githubAPIBaseURL)/repos/\(repositoryOwner)/\(repositoryName)/releases/latest"
		guard let url = URL(string: urlString) else {
			completion(.failure(UpdateError.invalidURL))
			return
		}
		
		var request = URLRequest(url: url)
		request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
		
		session.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let data = data else {
				completion(.failure(UpdateError.noData))
				return
			}
			
			do {
				let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
				let updateInfo = self.processRelease(release)
				completion(.success(updateInfo))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	private func processRelease(_ release: GitHubRelease) -> UpdateInfo? {
		let currentVersion = self.getCurrentVersion()
		let latestVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "v"))
		
		// Compare versions
		guard isVersionNewer(latestVersion, than: currentVersion) else {
			return nil // No updates available
		}
		
		// Look for DMG file in assets
		guard let dmgAsset = release.assets.first(where: { $0.name.hasSuffix(".dmg") }) else {
			return nil
		}
		
		let dateFormatter = ISO8601DateFormatter()
		let publishedDate = dateFormatter.date(from: release.publishedAt) ?? Date()
		
		return UpdateInfo(
			version: latestVersion,
			releaseNotes: release.body,
			downloadUrl: dmgAsset.browserDownloadUrl,
			publishedDate: publishedDate
		)
	}
	
	private func getCurrentVersion() -> String {
		let bundle = Bundle.main
		return bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
	}
	
	private func isVersionNewer(_ version1: String, than version2: String) -> Bool {
		let v1Components = version1.split(separator: ".").compactMap { Int($0) }
		let v2Components = version2.split(separator: ".").compactMap { Int($0) }
		
		let maxLength = max(v1Components.count, v2Components.count)
		
		for i in 0..<maxLength {
			let v1Value = i < v1Components.count ? v1Components[i] : 0
			let v2Value = i < v2Components.count ? v2Components[i] : 0
			
			if v1Value > v2Value {
				return true
			} else if v1Value < v2Value {
				return false
			}
		}
		
		return false
	}
	
	private func downloadUpdate(from urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
		guard let url = URL(string: urlString) else {
			completion(.failure(UpdateError.invalidURL))
			return
		}
		
		let documentsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
		let fileName = url.lastPathComponent
		let destinationURL = documentsPath.appendingPathComponent(fileName)
		
		// Remove old file if it exists
		try? FileManager.default.removeItem(at: destinationURL)
		
		session.downloadTask(with: url) { tempURL, response, error in
			if let error = error {
				completion(.failure(error))
				return
			}
			
			guard let tempURL = tempURL else {
				completion(.failure(UpdateError.noData))
				return
			}
			
			do {
				try FileManager.default.moveItem(at: tempURL, to: destinationURL)
				completion(.success(destinationURL))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
	
	private func installUpdate(from url: URL) {
		// Open DMG file
		NSWorkspace.shared.open(url)
		
		// Show notification to user
		showUpdateNotification()
	}
	
	private func showUpdateNotification() {
		let notification = NSUserNotification()
		notification.title = "AudioKeeper - Update Ready"
		notification.informativeText = "New version downloaded. Install it by dragging the app to the Applications folder."
		notification.soundName = NSUserNotificationDefaultSoundName
		
		NSUserNotificationCenter.default.deliver(notification)
	}
	
	private func saveLastCheckDate() {
		var preferences = preferencesStore.load(currentInputUID: nil, currentOutputUID: nil)
		preferences.lastUpdateCheck = lastCheckedDate
		preferencesStore.save(preferences)
	}
}

// MARK: - Update Errors
enum UpdateError: LocalizedError {
	case invalidURL
	case noData
	case invalidVersion
	case downloadFailed
	case installationFailed
	
	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid URL for update check"
		case .noData:
			return "No data to process"
		case .invalidVersion:
			return "Invalid version format"
		case .downloadFailed:
			return "Error downloading update"
		case .installationFailed:
			return "Error installing update"
		}
	}
}
