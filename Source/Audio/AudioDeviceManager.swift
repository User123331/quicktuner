import Foundation
import AudioBridge

/// Actor managing audio device enumeration and selection
/// Wraps Objective-C++ bridge with Swift-friendly AsyncStream API
actor AudioDeviceManager {

    // MARK: - Properties

    private let bridge = AudioDeviceManagerBridge()

    /// Currently selected device
    private(set) var selectedDevice: AudioDevice?

    private var deviceContinuation: AsyncStream<[AudioDevice]>.Continuation?

    /// AsyncStream of available input devices
    /// Updates when devices are added/removed (hot-plug support)
    func deviceStream() -> AsyncStream<[AudioDevice]> {
        AsyncStream { continuation in
            self.deviceContinuation = continuation

            // Initial enumeration
            Task {
                let devices = self.enumerateDevices()
                continuation.yield(devices)
            }
        }
    }

    // MARK: - Device Enumeration

    /// Enumerate all available input devices
    /// - Returns: Array of AudioDevice structs
    func enumerateDevices() -> [AudioDevice] {
        let deviceInfos = bridge.enumerateInputDevices()

        return deviceInfos.map { info in
            AudioDevice(
                id: info.deviceID,
                name: info.name,
                uid: info.uid,
                isInput: info.hasInput
            )
        }
    }

    /// Refresh device list and notify listeners
    func refreshDevices() {
        let devices = enumerateDevices()
        deviceContinuation?.yield(devices)
    }

    // MARK: - Device Selection

    /// Select an input device by ID
    /// - Parameter deviceID: The Core Audio device ID
    /// - Throws: Error if device cannot be selected
    func selectDevice(id deviceID: UInt32) async throws {
        do {
            try bridge.selectInputDevice(deviceID)

            // Update selected device
            let devices = enumerateDevices()
            selectedDevice = devices.first { $0.id == deviceID }

            // Persist selection
            if let device = selectedDevice {
                UserDefaults.standard.set(device.uid, forKey: Keys.selectedDeviceUID)
            }

            // Notify listeners
            deviceContinuation?.yield(devices)
        } catch {
            throw AudioDeviceError.selectionFailed
        }
    }

    /// Select a device by its UID string
    /// - Parameter uid: Device UID (persistent identifier)
    /// - Returns: True if device was found and selected
    @discardableResult
    func selectDeviceByUID(_ uid: String) async -> Bool {
        let devices = enumerateDevices()
        guard let device = devices.first(where: { $0.uid == uid }) else {
            return false
        }

        do {
            try await selectDevice(id: device.id)
            return true
        } catch {
            return false
        }
    }

    /// Select the system default input device
    func selectDefaultDevice() async {
        let defaultID = bridge.defaultInputDeviceID()
        if defaultID != 0 {
            try? await selectDevice(id: defaultID)
        }
    }

    /// Restore previously selected device from UserDefaults
    /// Falls back to default device if saved device unavailable
    func restoreSavedDevice() async {
        // Try saved device first
        if let savedUID = UserDefaults.standard.string(forKey: Keys.selectedDeviceUID) {
            let success = await selectDeviceByUID(savedUID)
            if success { return }
        }

        // Fall back to default
        await selectDefaultDevice()
    }

    /// Get the default input device ID
    var defaultDeviceID: UInt32 {
        bridge.defaultInputDeviceID()
    }

    /// Get device name by ID
    func nameForDevice(id: UInt32) -> String? {
        bridge.name(forDevice: id)
    }

    /// Get device UID by ID
    func uidForDevice(id: UInt32) -> String? {
        bridge.uid(forDevice: id)
    }

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let selectedDeviceUID = "SelectedAudioDeviceUID"
    }
}

// MARK: - Errors

enum AudioDeviceError: Error {
    case selectionFailed
    case deviceNotFound
    case permissionDenied
}

extension AudioDeviceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .selectionFailed:
            return "Failed to select audio device"
        case .deviceNotFound:
            return "Audio device not found"
        case .permissionDenied:
            return "Microphone access denied"
        }
    }
}

// MARK: - Polling-based Hot-swap Support

extension AudioDeviceManager {
    /// Start polling for device changes
    /// - Parameter interval: Polling interval in seconds (default: 2.0)
    /// - Returns: Task that can be cancelled to stop polling
    func startDeviceMonitoring(interval: TimeInterval = 2.0) -> Task<Void, Never> {
        return Task { @Sendable [weak self] in
            guard let self = self else { return }

            var lastDevices: [AudioDevice] = []

            while !Task.isCancelled {
                let currentDevices = await self.enumerateDevices()

                // Check for changes
                if currentDevices != lastDevices {
                    // Device added or removed
                    await self.handleDeviceChange(previous: lastDevices, current: currentDevices)
                    lastDevices = currentDevices
                }

                // Sleep before next poll
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    /// Handle device list changes
    private func handleDeviceChange(previous: [AudioDevice], current: [AudioDevice]) async {
        let previousIDs = Set(previous.map { $0.id })
        let currentIDs = Set(current.map { $0.id })

        let added = currentIDs.subtracting(previousIDs)
        let removed = previousIDs.subtracting(currentIDs)

        // Check if currently selected device was removed
        if let selected = selectedDevice, removed.contains(selected.id) {
            // Fall back to default device
            await selectDefaultDevice()
        }

        // Notify listeners of new device list
        deviceContinuation?.yield(current)

        // Log changes (for debugging)
        if !added.isEmpty {
            print("Audio devices added: \(added)")
        }
        if !removed.isEmpty {
            print("Audio devices removed: \(removed)")
        }
    }
}
