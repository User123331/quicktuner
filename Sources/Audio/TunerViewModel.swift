import Foundation
import SwiftUI

/// MainActor-isolated view model for tuner UI
/// Bridges AudioEngine AsyncStream to SwiftUI via @Observable
@MainActor
@Observable
final class TunerViewModel {

    // MARK: - Dependencies

    private let audioEngine = AudioEngine()
    private let deviceManager = AudioDeviceManager()

    // MARK: - Published State

    /// Current detected frequency in Hz (0 if no pitch)
    var frequency: Double = 0

    /// Current detected note (nil if no pitch or below threshold)
    var note: Note?

    /// Input level in dB for meter display (AUDIO-02)
    var inputLevelDb: Float = -60

    /// Whether pitch detection is currently running
    var isRunning = false

    /// Whether current signal is above noise gate threshold
    var hasSignal = false

    /// Confidence of current pitch detection (0.0-1.0)
    var confidence: Double = 0

    /// Available audio input devices
    var availableDevices: [AudioDevice] = []

    /// Currently selected device
    var selectedDevice: AudioDevice?

    /// Noise gate threshold in dB (user-configurable)
    var noiseGateThresholdDb: Float = Float(YINConfig.defaultNoiseGateDb)

    /// Reference pitch for A4 (user-configurable, 420-444 Hz)
    var referencePitch: Double = 440.0

    // MARK: - Private State

    private var audioTask: Task<Void, Never>?
    private var levelTask: Task<Void, Never>?
    private var isStopping = false

    // MARK: - Lifecycle

    init() {
        // Load saved settings
        noiseGateThresholdDb = UserDefaults.standard.float(forKey: Keys.noiseGateThreshold)
        if noiseGateThresholdDb == 0 { noiseGateThresholdDb = Float(YINConfig.defaultNoiseGateDb) }

        referencePitch = UserDefaults.standard.double(forKey: Keys.referencePitch)
        if referencePitch == 0 { referencePitch = 440.0 }
    }

    func prepareForDeinit() {
        isStopping = true
        audioTask?.cancel()
        levelTask?.cancel()
    }

    // MARK: - Public Methods

    /// Start the tuner
    /// Requests microphone permission if needed
    func start() async {
        // Check/request microphone permission
        let hasPermission = await checkMicrophonePermission()
        guard hasPermission else {
            print("Microphone permission denied")
            return
        }

        do {
            // Restore saved device or use default
            await deviceManager.restoreSavedDevice()
            selectedDevice = await deviceManager.selectedDevice

            // Start audio engine
            try await audioEngine.start()
            isRunning = true

            // Start consuming pitch stream
            audioTask = Task { @Sendable [weak self] in
                await self?.consumePitchStream()
            }

            // Start consuming level stream
            levelTask = Task { @Sendable [weak self] in
                await self?.consumeLevelStream()
            }

        } catch {
            print("Failed to start audio engine: \(error)")
            isRunning = false
        }
    }

    /// Stop the tuner
    func stop() async {
        audioTask?.cancel()
        levelTask?.cancel()
        await audioEngine.stop()
        isRunning = false
        frequency = 0
        note = nil
        hasSignal = false
    }

    /// Toggle tuner on/off
    func toggle() async {
        if isRunning {
            await stop()
        } else {
            await start()
        }
    }

    /// Select a different input device
    func selectDevice(_ device: AudioDevice) async {
        do {
            try await deviceManager.selectDevice(id: device.id)
            selectedDevice = device
        } catch {
            print("Failed to select device: \(error)")
        }
    }

    /// Refresh available devices
    func refreshDevices() async {
        availableDevices = await deviceManager.enumerateDevices()
    }

    /// Set noise gate threshold
    func setNoiseGateThreshold(_ db: Float) {
        noiseGateThresholdDb = db
        UserDefaults.standard.set(db, forKey: Keys.noiseGateThreshold)
    }

    // MARK: - Private Methods

    private func checkMicrophonePermission() async -> Bool {
        // For macOS, AVAudioSession is iOS-only
        // On macOS, permission is handled via entitlements + Info.plist
        // Return true for now; actual permission prompt happens on first mic access
        return true
    }

    /// Consume pitch results from AudioEngine
    private func consumePitchStream() async {
        let stream = await audioEngine.pitchStream

        for await result in stream {
            guard !Task.isCancelled else { break }

            await MainActor.run {
                self.updatePitch(result)
            }
        }
    }

    /// Consume level updates from AudioEngine
    private func consumeLevelStream() async {
        let stream = await audioEngine.levelStream

        for await level in stream {
            guard !Task.isCancelled else { break }

            await MainActor.run {
                self.inputLevelDb = level
                self.hasSignal = level > self.noiseGateThresholdDb
            }
        }
    }

    /// Update pitch from detection result
    private func updatePitch(_ result: PitchResult) {
        confidence = result.confidence

        // Apply noise gate: require signal above threshold AND good confidence
        guard hasSignal && result.confidence > YINConfig.confidenceThreshold else {
            // Keep last valid note briefly, then clear
            if !hasSignal {
                note = nil
                frequency = 0
            }
            return
        }

        frequency = result.frequency
        note = NoteClassifier.classify(frequency: result.frequency, referencePitch: referencePitch)
    }

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let noiseGateThreshold = "NoiseGateThresholdDb"
        static let referencePitch = "ReferencePitch"
    }
}

// MARK: - Helpers

extension TunerViewModel {
    /// Formatted frequency string for display
    var frequencyText: String {
        guard frequency > 0 else { return "--" }
        return String(format: "%.1f Hz", frequency)
    }

    /// Formatted note name for display
    var noteNameText: String {
        guard let note = note else { return "-" }
        return "\(note.name)\(note.octave)"
    }

    /// Formatted cents for display
    var centsText: String {
        guard let note = note else { return "--" }
        let sign = note.cents >= 0 ? "+" : ""
        return String(format: "%@%.0f¢", sign, note.cents)
    }

    /// Level meter value (0.0-1.0) for UI bar
    var levelMeterValue: Float {
        // Map -60dB to -20dB range to 0-1
        let minDb: Float = -60
        let maxDb: Float = -20
        let clamped = max(minDb, min(maxDb, inputLevelDb))
        return (clamped - minDb) / (maxDb - minDb)
    }
}
