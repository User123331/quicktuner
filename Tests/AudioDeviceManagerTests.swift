import XCTest
@testable import QuickTuner

@MainActor
final class AudioDeviceManagerTests: XCTestCase {

    var deviceManager: AudioDeviceManager!

    override func setUp() async throws {
        deviceManager = AudioDeviceManager()
    }

    override func tearDown() async throws {
        // Clean up UserDefaults
        UserDefaults.standard.removeObject(forKey: "SelectedAudioDeviceUID")
    }

    func testEnumerateDevices() async {
        let devices = await deviceManager.enumerateDevices()

        // Should have at least one device (built-in mic)
        XCTAssertGreaterThan(devices.count, 0, "Should have at least one input device")

        // Verify device properties
        for device in devices {
            XCTAssertGreaterThan(device.name.count, 0, "Device should have a name")
            XCTAssertGreaterThan(device.uid.count, 0, "Device should have a UID")
            XCTAssertTrue(device.isInput, "Device should be an input device")
        }
    }

    func testDefaultDeviceExists() async {
        let defaultID = await deviceManager.defaultDeviceID
        XCTAssertGreaterThan(defaultID, 0, "Should have a default device")

        let name = await deviceManager.nameForDevice(id: defaultID)
        XCTAssertNotNil(name, "Default device should have a name")
    }

    func testDeviceSelection() async throws {
        let devices = await deviceManager.enumerateDevices()
        guard let firstDevice = devices.first else {
            XCTSkip("No audio devices available")
            return
        }

        // Select the device
        try await deviceManager.selectDevice(id: firstDevice.id)

        // Verify selection
        let selected = await deviceManager.selectedDevice
        XCTAssertEqual(selected?.id, firstDevice.id)
        XCTAssertEqual(selected?.uid, firstDevice.uid)
    }

    func testDevicePersistence() async throws {
        let devices = await deviceManager.enumerateDevices()
        guard let firstDevice = devices.first else {
            XCTSkip("No audio devices available")
            return
        }

        // Select and persist
        try await deviceManager.selectDevice(id: firstDevice.id)

        // Verify saved in UserDefaults
        let savedUID = UserDefaults.standard.string(forKey: "SelectedAudioDeviceUID")
        XCTAssertEqual(savedUID, firstDevice.uid)
    }

    func testRestoreSavedDevice() async throws {
        let devices = await deviceManager.enumerateDevices()
        guard let firstDevice = devices.first else {
            XCTSkip("No audio devices available")
            return
        }

        // Save UID directly
        UserDefaults.standard.set(firstDevice.uid, forKey: "SelectedAudioDeviceUID")

        // Create new manager and restore
        let newManager = AudioDeviceManager()
        await newManager.restoreSavedDevice()

        let selected = await newManager.selectedDevice
        XCTAssertEqual(selected?.uid, firstDevice.uid)
    }

    func testFallbackToDefault() async {
        // Save invalid UID
        UserDefaults.standard.set("invalid-uid-12345", forKey: "SelectedAudioDeviceUID")

        // Create new manager and restore (should fall back)
        await deviceManager.restoreSavedDevice()

        let selected = await deviceManager.selectedDevice
        XCTAssertNotNil(selected, "Should have selected default device as fallback")
    }

    func testAsyncStreamYieldsDevices() async {
        let stream = await deviceManager.deviceStream()

        var receivedDevices: [[AudioDevice]] = []

        // Collect first emission
        for await devices in stream {
            receivedDevices.append(devices)
            if receivedDevices.count >= 1 { break }
        }

        XCTAssertEqual(receivedDevices.count, 1)
        XCTAssertGreaterThan(receivedDevices[0].count, 0)
    }
}
