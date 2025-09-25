import Foundation
import CoreAudio

protocol AudioDeviceMonitorDelegate: AnyObject {
	func defaultDeviceDidChange(role: AudioRole)
	func deviceListDidChange()
}

	final class AudioDeviceMonitor {
	weak var delegate: AudioDeviceMonitorDelegate?
	private var isStarted = false

	func start() {
		guard !isStarted else { return }
		isStarted = true

		var defaultInputAddr = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDefaultInputDevice,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)
		var defaultOutputAddr = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDefaultOutputDevice,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)
		var devicesAddr = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDevices,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)

		let systemObject = AudioObjectID(kAudioObjectSystemObject)

			// Add handlers with error checking
		let inputStatus = AudioObjectAddPropertyListenerBlock(systemObject, &defaultInputAddr, DispatchQueue.main) { [weak self] _, _ in
			self?.delegate?.defaultDeviceDidChange(role: .input)
		}
		if inputStatus != noErr {
			print("Warning: Failed to add input device listener: \(inputStatus)")
		}
		
		let outputStatus = AudioObjectAddPropertyListenerBlock(systemObject, &defaultOutputAddr, DispatchQueue.main) { [weak self] _, _ in
			self?.delegate?.defaultDeviceDidChange(role: .output)
		}
		if outputStatus != noErr {
			print("Warning: Failed to add output device listener: \(outputStatus)")
		}
		
		let devicesStatus = AudioObjectAddPropertyListenerBlock(systemObject, &devicesAddr, DispatchQueue.main) { [weak self] _, _ in
			self?.delegate?.deviceListDidChange()
		}
		if devicesStatus != noErr {
			print("Warning: Failed to add devices list listener: \(devicesStatus)")
		}
	}

	deinit {
		// Listeners will be automatically removed with block APIs when object deallocates
	}
}
