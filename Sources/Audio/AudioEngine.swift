import Foundation
import AVFAudio

/// Actor managing the audio capture and pitch detection pipeline
/// Three-layer threading: tap callback → AsyncStream → MainActor
actor AudioEngine {

    // MARK: - Properties

    private let engine = AVAudioEngine()
    private let ringBuffer = RingBuffer()
    private var analysisTask: Task<Void, Never>?

    /// AsyncStream of pitch detection results
    /// Consumers should use .throttle(for:.milliseconds(42), latest: true) for UI updates
    private var pitchContinuation: AsyncStream<PitchResult>.Continuation?

    /// Public stream for pitch results
    lazy var pitchStream: AsyncStream<PitchResult> = {
        AsyncStream { continuation in
            self.pitchContinuation = continuation
        }
    }()

    /// AsyncStream of input level updates for UI meter
    private var levelContinuation: AsyncStream<Float>.Continuation?
    lazy var levelStream: AsyncStream<Float> = {
        AsyncStream { continuation in
            self.levelContinuation = continuation
        }
    }()

    private var isRunning = false

    // MARK: - Lifecycle

    deinit {
        analysisTask?.cancel()
    }

    // MARK: - Public Methods

    /// Start audio capture and pitch detection
    /// - Throws: AVAudioEngine errors if configuration fails
    func start() async throws {
        guard !isRunning else { return }

        // Configure audio session
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Ensure format is compatible (mono or stereo float)
        if format.sampleRate != YINConfig.sampleRate {
            print("Warning: Sample rate mismatch. Expected \(YINConfig.sampleRate), got \(format.sampleRate)")
        }

        // Install tap on input node
        // bufferSize is a request, actual size may vary
        inputNode.installTap(onBus: 0,
                              bufferSize: YINConfig.tapBufferSize,
                              format: format) { [weak self] buffer, time in
            guard let self = self else { return }

            // CRITICAL: This runs on real-time audio thread
            // NO allocations, NO locks, NO MainActor calls here
            // Just copy to ring buffer

            if let channelData = buffer.floatChannelData {
                // Use first channel (mono)
                let frames = Int(buffer.frameLength)
                self.ringBuffer.write(channelData[0], count: frames)
            }
        }

        // Start the engine
        try engine.start()
        isRunning = true

        // Start analysis task on background queue
        analysisTask = Task { @Sendable [weak self] in
            await self?.analysisLoop()
        }
    }

    /// Stop audio capture
    func stop() async {
        guard isRunning else { return }

        analysisTask?.cancel()
        analysisTask = nil

        engine.stop()
        engine.inputNode.removeTap(onBus: 0)

        pitchContinuation?.finish()
        levelContinuation?.finish()

        isRunning = false
    }

    /// Check if engine is running
    var running: Bool { isRunning }

    // MARK: - Private Methods

    /// Background analysis loop
    /// Runs on non-MainActor, consumes from ring buffer
    private func analysisLoop() async {
        var analysisBuffer = [Float](repeating: 0, count: YINConfig.analysisWindowSize)
        let stepSize = Int(Double(YINConfig.analysisWindowSize) * (1.0 - YINConfig.overlapRatio))

        while !Task.isCancelled {
            // Wait for enough samples
            while ringBuffer.availableSamples < YINConfig.analysisWindowSize {
                try? await Task.sleep(nanoseconds: 500_000) // 0.5ms poll
                if Task.isCancelled { return }
            }

            // Read analysis window
            let samplesRead = ringBuffer.read(into: &analysisBuffer, count: YINConfig.analysisWindowSize)
            guard samplesRead == YINConfig.analysisWindowSize else { continue }

            // Calculate input level for meter (AUDIO-02)
            let rms = PitchDetector.rmsLevel(samples: analysisBuffer)
            let db = PitchDetector.rmsToDecibels(rms: rms)
            levelContinuation?.yield(db)

            // Run pitch detection (CPU intensive, off main thread)
            let result = PitchDetector.detect(
                samples: analysisBuffer,
                sampleRate: YINConfig.sampleRate
            )

            // Yield result to stream
            pitchContinuation?.yield(result)

            // Advance read position for overlap
            // Skip stepSize samples to achieve 50% overlap on next read
            if stepSize < YINConfig.analysisWindowSize {
                var skipBuffer = [Float](repeating: 0, count: stepSize)
                _ = ringBuffer.read(into: &skipBuffer, count: stepSize)
            }
        }
    }
}

// MARK: - Helper Extensions

extension AudioEngine {
    /// Current input format (for debugging)
    var inputFormat: AVAudioFormat? {
        engine.inputNode.outputFormat(forBus: 0)
    }

    // Note: macOS handles microphone permission via entitlements, not runtime API
    // The com.apple.security.device.audio-input entitlement in QuickTuner.entitlements
    // combined with NSMicrophoneUsageDescription in Info.plist is sufficient.
    // First microphone access triggers system permission dialog automatically.
}
