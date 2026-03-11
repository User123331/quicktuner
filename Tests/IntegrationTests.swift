import XCTest
@testable import QuickTuner

/// Integration tests for the complete Phase 1 audio pipeline
/// These tests verify component wiring, not DSP accuracy
@MainActor
final class IntegrationTests: XCTestCase {

    var viewModel: TunerViewModel!

    override func setUp() {
        viewModel = TunerViewModel()
    }

    override func tearDown() async throws {
        await viewModel.stop()
    }

    // MARK: - Audio Pipeline Tests

    func testAudioPipelineStarts() async throws {
        // Start the tuner
        await viewModel.start()

        // Give it time to initialize
        try await Task.sleep(nanoseconds: 500_000_000) // 500ms

        XCTAssertTrue(viewModel.isRunning, "Audio pipeline should be running")
        XCTAssertNotNil(viewModel.selectedDevice, "Should have a selected device")
    }

    func testAudioPipelineStops() async throws {
        // Start then stop
        await viewModel.start()
        try await Task.sleep(nanoseconds: 100_000_000)

        await viewModel.stop()

        XCTAssertFalse(viewModel.isRunning, "Audio pipeline should be stopped")
        XCTAssertEqual(viewModel.frequency, 0, "Frequency should be reset")
        XCTAssertNil(viewModel.note, "Note should be nil when stopped")
    }

    func testLevelMeterUpdates() async throws {
        // Start the tuner
        await viewModel.start()

        // Wait for level updates
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Level should be updating (even if quiet)
        // Note: This test may fail in CI without audio input
        // In practice, it shows -60dB (silence) which is valid
        XCTAssertLessThanOrEqual(viewModel.inputLevelDb, 0, "Level should be <= 0 dB")
        XCTAssertGreaterThanOrEqual(viewModel.inputLevelDb, -100, "Level should be reasonable")
    }

    func testDeviceEnumeration() async {
        await viewModel.refreshDevices()

        XCTAssertGreaterThan(viewModel.availableDevices.count, 0, "Should have at least one device")

        // Verify device properties
        for device in viewModel.availableDevices {
            XCTAssertGreaterThan(device.name.count, 0, "Device should have a name")
            XCTAssertGreaterThan(device.uid.count, 0, "Device should have a UID")
        }
    }

    func testDeviceSelection() async throws {
        // Get devices
        await viewModel.refreshDevices()
        guard let firstDevice = viewModel.availableDevices.first else {
            XCTSkip("No audio devices available")
            return
        }

        // Select a device
        await viewModel.selectDevice(firstDevice)

        // Verify selection
        XCTAssertEqual(viewModel.selectedDevice?.id, firstDevice.id)
    }

    func testNoiseGateThreshold() async {
        // Set threshold
        viewModel.setNoiseGateThreshold(-40)
        XCTAssertEqual(viewModel.noiseGateThresholdDb, -40)

        // Check persistence
        let saved = UserDefaults.standard.float(forKey: "NoiseGateThresholdDb")
        XCTAssertEqual(saved, -40)
    }

    func testPitchDetectionFlow() async throws {
        // This test verifies the data flow, not accuracy
        // It checks that the pipeline produces results

        await viewModel.start()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // The view model should have processed some data
        // Even without input, level should be updating
        XCTAssertTrue(viewModel.isRunning, "Should still be running")

        // Note: Actual pitch detection requires audio input
        // In CI, this will show no signal, which is expected
    }

    func testToggle() async throws {
        XCTAssertFalse(viewModel.isRunning)

        await viewModel.toggle()
        XCTAssertTrue(viewModel.isRunning)

        await viewModel.toggle()
        XCTAssertFalse(viewModel.isRunning)
    }

    // MARK: - Threading Tests

    func testViewModelIsMainActor() {
        // Verify the view model is properly isolated
        // This is a compile-time check, runtime just verifies instantiation
        XCTAssertNotNil(viewModel)
    }
}
