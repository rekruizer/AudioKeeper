import Foundation
import CoreAudio
import AudioToolbox

struct AudioDeviceInfo: Equatable, Hashable {
	let uid: String
	let name: String
	let isInput: Bool
	let isOutput: Bool
}

enum AudioRole {
	case input
	case output
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
			print("Failed to get device list size: \(status)")
			return [] 
		}

		let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
		var deviceIDs = Array(repeating: AudioDeviceID(0), count: deviceCount)

		status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize, &deviceIDs)
		guard status == noErr else { 
			print("Failed to get device list: \(status)")
			return [] 
		}

		return deviceIDs.compactMap { deviceID in
			// Skip "empty" devices and check validity
			guard deviceID != 0, isValidDevice(deviceID) else { return nil }
			
			guard let uid = getString(deviceID: deviceID, selector: kAudioDevicePropertyDeviceUID) else { return nil }
			let name = getString(deviceID: deviceID, selector: kAudioObjectPropertyName) ?? uid
			let hasInput = streamDirectionExists(deviceID: deviceID, scope: kAudioDevicePropertyScopeInput)
			let hasOutput = streamDirectionExists(deviceID: deviceID, scope: kAudioDevicePropertyScopeOutput)
			
					// Return only devices with at least one direction (input or output)
			guard hasInput || hasOutput else { return nil }
			
			return AudioDeviceInfo(uid: uid, name: name, isInput: hasInput, isOutput: hasOutput)
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

	func setDefaultDevice(uid: String, role: AudioRole) {
		guard let deviceID = deviceID(forUID: uid) else { 
			print("Device with UID \(uid) not found")
			return 
		}
		let selector: AudioObjectPropertySelector = (role == .input) ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice
		var address = AudioObjectPropertyAddress(mSelector: selector, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMain)
		var dev = deviceID
		let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &dev)
		if status != noErr {
			print("Failed to set default \(role) device: \(status)")
		} else {
			print("Successfully set default \(role) device to \(uid)")
		}
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
			print("Failed to get device list size: \(status)")
			return nil 
		}
		
		let count = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
		var ids = Array(repeating: AudioDeviceID(0), count: count)
		
		let getStatus = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize, &ids)
		guard getStatus == noErr else { 
			print("Failed to get device list: \(getStatus)")
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
		let cfStr = "" as CFString
		var s = cfStr
		let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &dataSize, &s)
		guard status == noErr else { return nil }
		return s as String
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
