import Foundation
import SwiftUI
import Observation

/// MainActor-isolated view model for tuner UI
/// Bridges AudioEngine AsyncStream to SwiftUI via @Observable
/// Manages string navigation, EMA smoothing, and in-tune detection
@MainActor
@Observable
final class TunerViewModel {

    // MARK: - Dependencies

    private let audioEngine: AudioEngine
    private let deviceManager: AudioDeviceManager
    private var audioTask: Task<Void, Never>?
    private var levelTask: Task<Void, Never>?
    private var isStopping = false

    // MARK: - Phase 3: Tuning Library and Persistence

    /// Tuning library for instrument/tuning management
    let tuningLibrary: TuningLibrary

    /// Persistence service for custom tunings
    private let persistenceService: PersistenceService

    /// Reference pitch for A4 (user-configurable, 420-444 Hz)
    /// Persisted via @AppStorage
    var referencePitch: Double {
        didSet {
            // Normalize and save when changed
            let normalized = ReferencePitchConstants.normalize(referencePitch)
            if normalized != referencePitch {
                referencePitch = normalized
            }
            UserDefaults.standard.set(referencePitch, forKey: PersistenceKeys.referencePitch)
        }
    }

    /// Currently selected instrument type
    /// Persisted via custom setter
    var selectedInstrument: InstrumentType {
        didSet {
            tuningLibrary.selectedInstrument = selectedInstrument
            UserDefaults.standard.set(selectedInstrument.rawValue, forKey: PersistenceKeys.selectedInstrument)
        }
    }

    /// Currently selected tuning ID for persistence restoration
    /// Persisted via custom restoration logic
    private var selectedTuningId: String? {
        didSet {
            UserDefaults.standard.set(selectedTuningId, forKey: PersistenceKeys.selectedTuningId)
        }
    }

    // MARK: - Display State (PITCH-03, PITCH-04)

    /// Current detected frequency in Hz (0 if no pitch)
    var frequency: Double = 0

    /// Current detected note (nil if no pitch or below threshold)
    var note: Note?

    /// Current detected note (alias for note property)
    var currentNote: Note? { note }

    /// Smoothed cents value (EMA applied)
    var cents: Double = 0

    /// Formatted cents display string (e.g., "+5", "-12", "0", "--")
    var centsDisplay: String = "--"

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

    /// Currently selected string index (0-based, default: 0 for String 1)
    var selectedStringIndex: Int = 0

    /// Array of strings for current instrument (default: standard guitar)
    var strings: [StringInfo] = StringInfo.standardGuitar

    /// Set of tuned string indices (0-based)
    var tunedStrings: Set<Int> = []

    // MARK: - In-Tune State Machine (PITCH-05)

    /// Whether the current pitch is in tune (±2 cents, 200ms hold)
    var isInTune: Bool = false

    /// Whether to show the "All Tuned" badge
    var showAllTunedBadge: Bool = false

    /// Timer task for 200ms hold requirement
    private var inTuneHoldTask: Task<Void, Never>?

    /// Timestamp when in-tune threshold was first reached
    private var inTuneStartTime: Date?

    /// Task for 500ms delay before showing All Tuned badge
    private var allTunedDelayTask: Task<Void, Never>?

    /// Threshold for entering in-tune state (cents)
    private let inTuneThreshold: Double = 2.0

    /// Threshold for exiting in-tune state (with hysteresis)
    private let outOfTuneThreshold: Double = 3.0

    /// Required hold time before confirming in-tune (seconds)
    private let inTuneHoldDuration: TimeInterval = 0.2

    /// Delay before showing All Tuned badge (nanoseconds)
    private let allTunedDelayNanoseconds: UInt64 = 500_000_000

    // MARK: - EMA Smoothing State (PITCH-02)

    /// Previous smoothed cents value for EMA calculation
    private var previousCents: Double = 0

    /// EMA smoothing factor (alpha = 0.3 per Phase 2 context)
    private let alpha = 0.3

    // MARK: - Initialization

    /// Initialize with default audio engine
    init(
        tuningLibrary: TuningLibrary = TuningLibrary(),
        persistenceService: PersistenceService = .shared
    ) {
        self.audioEngine = AudioEngine()
        self.deviceManager = AudioDeviceManager()
        self.tuningLibrary = tuningLibrary
        self.persistenceService = persistenceService

        // Load saved settings from UserDefaults
        let savedNoiseGate = UserDefaults.standard.float(forKey: PersistenceKeys.noiseGateThreshold)
        if savedNoiseGate == 0 {
            self.noiseGateThresholdDb = Float(YINConfig.defaultNoiseGateDb)
        } else {
            self.noiseGateThresholdDb = savedNoiseGate
        }

        let savedRefPitch = UserDefaults.standard.double(forKey: PersistenceKeys.referencePitch)
        if savedRefPitch == 0 {
            self.referencePitch = ReferencePitchConstants.default
        } else {
            self.referencePitch = ReferencePitchConstants.normalize(savedRefPitch)
        }

        // Restore saved instrument
        if let savedInstrumentRaw = UserDefaults.standard.string(forKey: PersistenceKeys.selectedInstrument),
           let savedInstrument = InstrumentType(rawValue: savedInstrumentRaw) {
            self.selectedInstrument = savedInstrument
        } else {
            self.selectedInstrument = .guitar6
        }
        self.tuningLibrary.selectedInstrument = self.selectedInstrument

        // Load custom tunings and restore selected tuning
        Task {
            await loadCustomTunings()
            await restoreSelectedTuning()
        }
    }

    func prepareForDeinit() {
        isStopping = true
        audioTask?.cancel()
        levelTask?.cancel()
        inTuneHoldTask?.cancel()
        allTunedDelayTask?.cancel()
    }

    // MARK: - Lifecycle

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

    // MARK: - Pitch Stream Processing

    /// Start consuming pitch results from the audio engine (testing path)
    private func startPitchStream() {
        audioTask = Task { @Sendable [weak self] in
            await self?.consumePitchStream()
        }

        levelTask = Task { @Sendable [weak self] in
            await self?.consumeLevelStream()
        }
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
                centsDisplay = "--"
            }
            return
        }

        frequency = result.frequency
        note = NoteClassifier.classify(frequency: result.frequency, referencePitch: referencePitch)

        // Apply EMA smoothing to cents (if note has cents)
        if let currentNote = note {
            let smoothedCents = applyEMA(currentNote.cents)
            self.cents = smoothedCents
            updateCentsDisplay(smoothedCents)

            // Check in-tune state
            checkInTuneState(smoothedCents)
        }
    }

    // MARK: - EMA Smoothing (PITCH-02)

    /// Apply Exponential Moving Average smoothing to raw cents value
    /// Formula: smoothed = (alpha * current) + ((1 - alpha) * previous)
    /// - Parameter rawCents: The raw cents value from pitch detection
    /// - Returns: The smoothed cents value
    func applyEMA(_ rawCents: Double) -> Double {
        let smoothed = (alpha * rawCents) + ((1 - alpha) * previousCents)
        previousCents = smoothed
        return smoothed
    }

    /// Reset EMA smoothing state
    func resetEMA() {
        previousCents = 0
        cents = 0
    }

    // MARK: - Cents Display

    /// Update the cents display string based on smoothed value
    /// - Parameter smoothedCents: The EMA-smoothed cents value
    private func updateCentsDisplay(_ smoothedCents: Double) {
        let intCents = Int(round(smoothedCents))
        if intCents == 0 {
            centsDisplay = "0"
        } else if intCents > 0 {
            centsDisplay = "+\(intCents)"
        } else {
            centsDisplay = "\(intCents)"
        }
    }

    // MARK: - In-Tune State Machine (PITCH-05)

    /// Check and update in-tune state based on cents deviation
    /// Implements ±2 cents threshold with 200ms hold and hysteresis
    /// - Parameter centsValue: The current cents deviation
    func checkInTuneState(_ centsValue: Double) {
        let absCents = abs(centsValue)

        if isInTune {
            // Currently in tune - check if we should exit
            if absCents > outOfTuneThreshold {
                // Exit in-tune state (hysteresis prevents flicker)
                isInTune = false
                inTuneStartTime = nil
                inTuneHoldTask?.cancel()
                inTuneHoldTask = nil
            }
        } else {
            // Not in tune - check if we should enter
            if absCents <= inTuneThreshold {
                if inTuneStartTime == nil {
                    // First time within threshold - start the hold timer
                    inTuneStartTime = Date()
                    startInTuneHoldTimer()
                }
            } else {
                // Left the in-tune zone before hold completed
                inTuneStartTime = nil
                inTuneHoldTask?.cancel()
                inTuneHoldTask = nil
            }
        }
    }

    /// Start the 200ms hold timer for in-tune confirmation
    private func startInTuneHoldTimer() {
        inTuneHoldTask?.cancel()
        inTuneHoldTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(0.2 * 1_000_000_000)) // 200ms

            guard let self = self, !Task.isCancelled else { return }

            // Check if still within threshold
            if let startTime = self.inTuneStartTime,
               Date().timeIntervalSince(startTime) >= self.inTuneHoldDuration {
                self.isInTune = true
                // Mark current string as tuned if not already
                self.markStringAsTuned(at: self.selectedStringIndex)
                self.checkAllStringsTuned()
            }
        }
    }

    /// Check if all strings are tuned and update badge state with 500ms delay
    private func checkAllStringsTuned() {
        // Cancel any existing delay task
        allTunedDelayTask?.cancel()
        allTunedDelayTask = nil

        guard tunedStrings.count == strings.count else {
            // Not all tuned - badge stays hidden
            return
        }

        // All strings tuned - start 500ms delay before showing badge
        allTunedDelayTask = Task { @MainActor [weak self] in
            guard let self = self else { return }

            try? await Task.sleep(nanoseconds: self.allTunedDelayNanoseconds)

            guard !Task.isCancelled else { return }

            // Still all tuned after delay - show badge
            if self.tunedStrings.count == self.strings.count {
                self.showAllTunedBadge = true
            }
        }
    }

    // MARK: - String Navigation (NAV-01, NAV-02, NAV-04)

    /// Select a specific string by index
    /// - Parameter index: 0-based index of the string to select
    func selectString(at index: Int) {
        guard index >= 0 && index < strings.count else { return }
        selectedStringIndex = index
    }

    /// Select the previous string (higher pitch, lower index for guitar)
    func selectPreviousString() {
        if selectedStringIndex > 0 {
            selectedStringIndex -= 1
        }
    }

    /// Select the next string (lower pitch, higher index for guitar)
    func selectNextString() {
        if selectedStringIndex < strings.count - 1 {
            selectedStringIndex += 1
        }
    }

    // MARK: - Tuned String Tracking (NAV-04)

    /// Mark a specific string as tuned
    /// - Parameter index: 0-based index of the string
    func markStringAsTuned(at index: Int) {
        guard index >= 0 && index < strings.count else { return }
        tunedStrings.insert(index)
        strings[index].isTuned = true

        // Check if all strings are tuned
        checkAllStringsTuned()
    }

    /// Reset all tuned strings and return to String 1
    func resetTunedStrings() {
        tunedStrings.removeAll()
        for i in 0..<strings.count {
            strings[i].isTuned = false
        }
        selectedStringIndex = 0
        isInTune = false
        inTuneStartTime = nil
        inTuneHoldTask?.cancel()
        inTuneHoldTask = nil
        showAllTunedBadge = false
        allTunedDelayTask?.cancel()
        allTunedDelayTask = nil
    }

    /// Dismiss the "All Tuned" badge
    func dismissAllTunedBadge() {
        showAllTunedBadge = false
    }

    // MARK: - Device Management

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
        UserDefaults.standard.set(db, forKey: PersistenceKeys.noiseGateThreshold)
    }

    // MARK: - Persistence Methods

    /// Load custom tunings from persistence
    private func loadCustomTunings() async {
        let customTunings = await persistenceService.loadCustomTunings()
        for tuning in customTunings {
            tuningLibrary.addCustomTuning(tuning)
        }
    }

    /// Restore selected tuning from saved ID
    private func restoreSelectedTuning() async {
        if let savedTuningId = UserDefaults.standard.string(forKey: PersistenceKeys.selectedTuningId),
           let uuid = UUID(uuidString: savedTuningId) {
            tuningLibrary.selectTuning(id: uuid)
            selectedTuningId = savedTuningId
        }
    }

    /// Select a tuning and persist the selection
    func selectTuning(_ tuning: Tuning) {
        tuningLibrary.selectTuning(tuning)
        selectedTuningId = tuning.id.uuidString
    }

    /// Save a custom tuning and persist to disk
    func saveCustomTuning(_ tuning: Tuning) async throws {
        tuningLibrary.addCustomTuning(tuning)
        let allCustom = tuningLibrary.customTunings
        try await persistenceService.saveCustomTunings(allCustom)
    }

    /// Delete a custom tuning and persist changes
    func deleteCustomTuning(id: UUID) async throws {
        tuningLibrary.removeCustomTuning(id: id)
        let allCustom = tuningLibrary.customTunings
        try await persistenceService.saveCustomTunings(allCustom)
    }

    // MARK: - Private Methods

    private func checkMicrophonePermission() async -> Bool {
        // For macOS, AVAudioSession is iOS-only
        // On macOS, permission is handled via entitlements + Info.plist
        // Return true for now; actual permission prompt happens on first mic access
        return true
    }
}

// MARK: - Display Helpers

extension TunerViewModel {
    /// Formatted frequency string for display
    var frequencyText: String {
        guard frequency > 0 else { return "--" }
        return String(format: "%.1f Hz", frequency)
    }

    /// Formatted note name for display
    var noteNameText: String {
        guard let note = note else { return "--" }
        return "\(note.name)\(note.octave)"
    }

    /// Legacy cents text (with cent symbol)
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

    /// Whether the currently selected string is tuned
    var isSelectedStringTuned: Bool {
        tunedStrings.contains(selectedStringIndex)
    }

    /// Whether all strings are tuned
    var allStringsTuned: Bool {
        tunedStrings.count == strings.count
    }

    /// The currently selected string info
    var selectedString: StringInfo? {
        guard selectedStringIndex >= 0 && selectedStringIndex < strings.count else {
            return nil
        }
        return strings[selectedStringIndex]
    }

    /// Target frequency for the currently selected string
    var targetFrequency: Double? {
        selectedString?.note.frequency
    }
}
