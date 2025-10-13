import Foundation
import CoreAudio
import os.log

protocol AudioDeviceMonitorDelegate: AnyObject {
	func defaultDeviceDidChange(role: AudioRole)
	func deviceListDidChange()
}

final class AudioDeviceMonitor {
	weak var delegate: AudioDeviceMonitorDelegate?
	private var isStarted = false

	// Store property addresses for cleanup
	private var defaultInputAddr = AudioObjectPropertyAddress(
		mSelector: kAudioHardwarePropertyDefaultInputDevice,
		mScope: kAudioObjectPropertyScopeGlobal,
		mElement: kAudioObjectPropertyElementMain
	)
	private var defaultOutputAddr = AudioObjectPropertyAddress(
		mSelector: kAudioHardwarePropertyDefaultOutputDevice,
		mScope: kAudioObjectPropertyScopeGlobal,
		mElement: kAudioObjectPropertyElementMain
	)
	private var devicesAddr = AudioObjectPropertyAddress(
		mSelector: kAudioHardwarePropertyDevices,
		mScope: kAudioObjectPropertyScopeGlobal,
		mElement: kAudioObjectPropertyElementMain
	)

	// Store listener blocks for removal
	private var inputListenerBlock: AudioObjectPropertyListenerBlock?
	private var outputListenerBlock: AudioObjectPropertyListenerBlock?
	private var devicesListenerBlock: AudioObjectPropertyListenerBlock?

	func start() {
		guard !isStarted else { return }
		isStarted = true

		let systemObject = AudioObjectID(kAudioObjectSystemObject)

		// Add handlers with error checking and store blocks for cleanup
		inputListenerBlock = { [weak self] _, _ in
			self?.delegate?.defaultDeviceDidChange(role: .input)
		}
		let inputStatus = AudioObjectAddPropertyListenerBlock(systemObject, &defaultInputAddr, DispatchQueue.main, inputListenerBlock!)
		if inputStatus != noErr {
			Logger.audio.error("Failed to add input device listener: \(inputStatus)")
		}

		outputListenerBlock = { [weak self] _, _ in
			self?.delegate?.defaultDeviceDidChange(role: .output)
		}
		let outputStatus = AudioObjectAddPropertyListenerBlock(systemObject, &defaultOutputAddr, DispatchQueue.main, outputListenerBlock!)
		if outputStatus != noErr {
			Logger.audio.error("Failed to add output device listener: \(outputStatus)")
		}

		devicesListenerBlock = { [weak self] _, _ in
			self?.delegate?.deviceListDidChange()
		}
		let devicesStatus = AudioObjectAddPropertyListenerBlock(systemObject, &devicesAddr, DispatchQueue.main, devicesListenerBlock!)
		if devicesStatus != noErr {
			Logger.audio.error("Failed to add devices list listener: \(devicesStatus)")
		}

		Logger.audio.info("AudioDeviceMonitor started successfully")
	}

	func stop() {
		guard isStarted else { return }

		let systemObject = AudioObjectID(kAudioObjectSystemObject)

		// Remove input listener
		if let block = inputListenerBlock {
			let status = AudioObjectRemovePropertyListenerBlock(systemObject, &defaultInputAddr, DispatchQueue.main, block)
			if status != noErr {
				Logger.audio.error("Failed to remove input device listener: \(status)")
			}
			inputListenerBlock = nil
		}

		// Remove output listener
		if let block = outputListenerBlock {
			let status = AudioObjectRemovePropertyListenerBlock(systemObject, &defaultOutputAddr, DispatchQueue.main, block)
			if status != noErr {
				Logger.audio.error("Failed to remove output device listener: \(status)")
			}
			outputListenerBlock = nil
		}

		// Remove devices list listener
		if let block = devicesListenerBlock {
			let status = AudioObjectRemovePropertyListenerBlock(systemObject, &devicesAddr, DispatchQueue.main, block)
			if status != noErr {
				Logger.audio.error("Failed to remove devices list listener: \(status)")
			}
			devicesListenerBlock = nil
		}

		isStarted = false
		Logger.audio.info("AudioDeviceMonitor stopped successfully")
	}

	deinit {
		// Explicitly remove all listeners before deallocation
		stop()
	}
}
