import Cocoa
import SwiftUI
import Combine

final class AppState: ObservableObject, AudioDeviceMonitorDelegate {
	@Published var preferences: Preferences
	@Published var devices: [AudioDeviceInfo] = []

	private let store = PreferencesStore.shared
	private let switcher = AudioSwitcher.shared
	private let monitor = AudioDeviceMonitor()

	init() {
		let currentIn = switcher.getDefaultDeviceUID(role: .input)
		let currentOut = switcher.getDefaultDeviceUID(role: .output)
		self.preferences = store.load(currentInputUID: currentIn, currentOutputUID: currentOut)
		self.devices = switcher.listDevices()
		monitor.delegate = self
		monitor.start()
	}

	func defaultDeviceDidChange(role: AudioRole) {
		// Простая логика: если приложение активно и есть предпочтение, возвращаем к нему
		guard preferences.isActive else { return }
		
		// Небольшая задержка для стабильности
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			guard let self else { return }
			
			switch role {
			case .input:
				if let preferredUID = self.preferences.preferredInputUID,
				   let currentUID = self.switcher.getDefaultDeviceUID(role: .input),
				   currentUID != preferredUID {
					self.switcher.setDefaultDevice(uid: preferredUID, role: .input)
				}
			case .output:
				if let preferredUID = self.preferences.preferredOutputUID,
				   let currentUID = self.switcher.getDefaultDeviceUID(role: .output),
				   currentUID != preferredUID {
					self.switcher.setDefaultDevice(uid: preferredUID, role: .output)
				}
			}
		}
	}

	func deviceListDidChange() {
		// Refresh device list; this often precedes default change when a new device connects
		self.devices = switcher.listDevices()
	}

	func setActive(_ isActive: Bool) {
		preferences.isActive = isActive
		store.save(preferences)
		
		// При активации сразу устанавливаем предпочтения
		if isActive {
			if let inputUID = preferences.preferredInputUID {
				switcher.setDefaultDevice(uid: inputUID, role: .input)
			}
			if let outputUID = preferences.preferredOutputUID {
				switcher.setDefaultDevice(uid: outputUID, role: .output)
			}
		}
	}

	func setPreferredInput(uid: String?) {
		preferences.preferredInputUID = uid
		store.save(preferences)
		
		// Немедленно переключаем устройство в системе, если приложение активно
		if preferences.isActive, let uid = uid {
			switcher.setDefaultDevice(uid: uid, role: .input)
		}
	}

	func setPreferredOutput(uid: String?) {
		preferences.preferredOutputUID = uid
		store.save(preferences)
		
		// Немедленно переключаем устройство в системе, если приложение активно
		if preferences.isActive, let uid = uid {
			switcher.setDefaultDevice(uid: uid, role: .output)
		}
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	static let sharedState = AppState()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		// Убеждаемся, что приложение полностью скрыто (не в Dock, не в Command+Tab)
		NSApp.setActivationPolicy(.prohibited)
	}
}

struct AppMenuView: View {
	@ObservedObject var state = AppDelegate.sharedState

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			// Переключатель активности
			Toggle("Активно", isOn: Binding(
				get: { state.preferences.isActive },
				set: { state.setActive($0) }
			))
			.padding(.horizontal, 12)
			.padding(.vertical, 4)

			Divider()

			// Выбор устройства ввода
			VStack(alignment: .leading, spacing: 2) {
				Text("Ввод:")
					.font(.caption)
					.foregroundColor(.secondary)
					.padding(.horizontal, 12)
				
				Picker("Input Device", selection: Binding(
					get: { state.preferences.preferredInputUID ?? "" },
					set: { state.setPreferredInput(uid: $0.isEmpty ? nil : $0) }
				)) {
					Text("Системное по умолчанию").tag("")
					ForEach(state.devices.filter { $0.isInput }, id: \.uid) { device in
						Text(device.name).tag(device.uid)
					}
				}
				.pickerStyle(.menu)
				.padding(.horizontal, 12)
			}

			// Выбор устройства вывода
			VStack(alignment: .leading, spacing: 2) {
				Text("Вывод:")
					.font(.caption)
					.foregroundColor(.secondary)
					.padding(.horizontal, 12)
				
				Picker("Output Device", selection: Binding(
					get: { state.preferences.preferredOutputUID ?? "" },
					set: { state.setPreferredOutput(uid: $0.isEmpty ? nil : $0) }
				)) {
					Text("Системное по умолчанию").tag("")
					ForEach(state.devices.filter { $0.isOutput }, id: \.uid) { device in
						Text(device.name).tag(device.uid)
					}
				}
				.pickerStyle(.menu)
				.padding(.horizontal, 12)
			}

			Divider()
			
			Button("Выход") { 
				NSApp.terminate(nil) 
			}
			.padding(.horizontal, 12)
			.padding(.vertical, 4)
		}
		.padding(.vertical, 8)
		.frame(minWidth: 200)
	}
}
