import Foundation
import CoreAudio
import AudioToolbox
import os.log

struct AudioDeviceInfo: Equatable, Hashable {
	let uid: String
	let name: String
	let isInput: Bool
	let isOutput: Bool
	let isAvailable: Bool
}

enum AudioRole: CustomStringConvertible {
	case input
	case output

	var description: String {
		switch self {
		case .input: return "input"
		case .output: return "output"
		}
	}
}

enum AudioSwitcherError: Error, CustomStringConvertible {
	case deviceNotFound(uid: String)
	case setPropertyFailed(status: OSStatus, role: AudioRole)
	case systemError(OSStatus)

	var description: String {
		switch self {
		case .deviceNotFound(let uid):
			return "Device not found: \(uid)"
		case .setPropertyFailed(let status, let role):
			return "Failed to set default \(role) device (status: \(status))"
		case .systemError(let status):
			return "CoreAudio system error: \(status)"
		}
	}
}

final class AudioSwitcher {
	static let shared = AudioSwitcher()

	func listDevices() -> [AudioDeviceInfo] {
		var propertyAddress = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDevices,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)

		var dataSize: UInt32 = 0
		var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize)
		guard status == noErr && dataSize > 0 else {
			Logger.audio.error("Failed to get device list size: \(status)")
			return []
		}

		let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
		var deviceIDs = Array(repeating: AudioDeviceID(0), count: deviceCount)

		status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize, &deviceIDs)
		guard status == noErr else {
			Logger.audio.error("Failed to get device list: \(status)")
			return []
		}

		return deviceIDs.compactMap { deviceID in
			// Skip "empty" devices and check validity
			guard deviceID != 0 else { return nil }

			let isAvailable = isValidDevice(deviceID)
			guard let uid = getString(deviceID: deviceID, selector: kAudioDevicePropertyDeviceUID) else { return nil }
			let name = getString(deviceID: deviceID, selector: kAudioObjectPropertyName) ?? uid
			let hasInput = streamDirectionExists(deviceID: deviceID, scope: kAudioDevicePropertyScopeInput)
			let hasOutput = streamDirectionExists(deviceID: deviceID, scope: kAudioDevicePropertyScopeOutput)

			// Return only devices with at least one direction (input or output)
			guard hasInput || hasOutput else { return nil }

			return AudioDeviceInfo(uid: uid, name: name, isInput: hasInput, isOutput: hasOutput, isAvailable: isAvailable)
		}
	}

	func getDefaultDeviceUID(role: AudioRole) -> String? {
		let selector: AudioObjectPropertySelector = (role == .input) ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice
		var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
		var deviceID = AudioDeviceID(0)
		var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
		let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceID)
		guard status == noErr else { return nil }
		return getString(deviceID: deviceID, selector: kAudioDevicePropertyDeviceUID)
	}

	func setDefaultDevice(uid: String, role: AudioRole) -> Result<Void, AudioSwitcherError> {
		guard let deviceID = deviceID(forUID: uid) else {
			Logger.audio.warning("Device with UID \(uid) not found")
			return .failure(.deviceNotFound(uid: uid))
		}

		// Retry logic: attempt up to 3 times with 1 second delay
		let maxAttempts = 3
		var lastStatus: OSStatus = noErr

		for attempt in 1...maxAttempts {
			let selector: AudioObjectPropertySelector = (role == .input) ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice
			var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
			var dev = deviceID
			let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &dev)

			if status == noErr {
				Logger.audio.info("Successfully set default \(role) device to \(uid) (attempt \(attempt)/\(maxAttempts))")
				return .success(())
			}

			lastStatus = status
			Logger.audio.warning("Failed to set default \(role) device (attempt \(attempt)/\(maxAttempts)): \(status)")

			// Wait before retry (except on last attempt)
			if attempt < maxAttempts {
				Thread.sleep(forTimeInterval: 1.0)
			}
		}

		// All attempts failed
		Logger.audio.error("Failed to set default \(role) device after \(maxAttempts) attempts: \(lastStatus)")
		return .failure(.setPropertyFailed(status: lastStatus, role: role))
	}

	private func deviceID(forUID uid: String) -> AudioDeviceID? {
		var propertyAddress = AudioObjectPropertyAddress(
			mSelector: kAudioHardwarePropertyDevices,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)
		
		var dataSize: UInt32 = 0
		let status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize)
		guard status == noErr && dataSize > 0 else {
			Logger.audio.error("Failed to get device list size: \(status)")
			return nil
		}
		
		let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
		var ids = Array(repeating: AudioDeviceID(0), count: count)
		
		let getStatus = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize, &ids)
		guard getStatus == noErr else {
			Logger.audio.error("Failed to get device list: \(getStatus)")
			return nil
		}
		
		for id in ids {
					// Check that device actually exists and is available
			if isValidDevice(id) {
				if let deviceUID = getString(deviceID: id, selector: kAudioDevicePropertyDeviceUID),
				   deviceUID == uid {
					return id
				}
			}
		}
		return nil
	}
	
	private func isValidDevice(_ deviceID: AudioDeviceID) -> Bool {
		// Check that device is available and not "empty"
		var address = AudioObjectPropertyAddress(
			mSelector: kAudioDevicePropertyDeviceUID,
			mScope: kAudioObjectPropertyScopeGlobal,
			mElement: kAudioObjectPropertyElementMain
		)
		
		var dataSize: UInt32 = 0
		let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize)
		return status == noErr && dataSize > 0
	}

	private func getString(deviceID: AudioDeviceID, selector: AudioObjectPropertySelector) -> String? {
		var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
		var dataSize: UInt32 = 0
		guard AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize) == noErr else { return nil }

		var cfString: Unmanaged<CFString>?
		let status = withUnsafeMutablePointer(to: &cfString) { ptr in
			AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, ptr)
		}

		guard status == noErr, let unwrapped = cfString?.takeUnretainedValue() else { return nil }
		return unwrapped as String
	}

	private func streamDirectionExists(deviceID: AudioDeviceID, scope: AudioObjectPropertyScope) -> Bool {
		var address = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreams, mScope: scope, mElement: kAudioObjectPropertyElementMain)
		var dataSize: UInt32 = 0
		let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &dataSize)
		if status != noErr { return false }
		let count = Int(dataSize) / MemoryLayout<AudioStreamID>.size
		return count > 0
	}
}
