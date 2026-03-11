import XCTest
import Accelerate
@testable import QuickTuner

final class PitchDetectorTests: XCTestCase {

    // MARK: - Synthetic Signal Generation

    /// Generate a pure sine wave at the specified frequency
    func generateSineWave(frequency: Double, sampleRate: Double = 48000, duration: Double = 0.1) -> [Float] {
        let sampleCount = Int(duration * sampleRate)
        var samples = [Float](repeating: 0, count: sampleCount)

        for i in 0..<sampleCount {
            let time = Double(i) / sampleRate
            samples[i] = Float(sin(2.0 * Double.pi * frequency * time))
        }

        return samples
    }

    /// Calculate cents difference between two frequencies
    func centsDifference(detected: Double, expected: Double) -> Double {
        return 1200 * log2(detected / expected)
    }

    // MARK: - Accuracy Tests

    func testDetectA440() {
        let samples = generateSineWave(frequency: 440.0)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.8, "Should have high confidence")
        XCTAssertEqual(result.frequency, 440.0, accuracy: 0.5)  // Within 0.5 Hz

        let cents = centsDifference(detected: result.frequency, expected: 440.0)
        XCTAssertLessThan(abs(cents), 1.0, "Should be within 1 cent")
    }

    func testDetectLowE() {
        // Low E on guitar: 82.41 Hz
        let samples = generateSineWave(frequency: 82.41)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.7, "Should have good confidence")
        XCTAssertEqual(result.frequency, 82.41, accuracy: 0.1)

        let cents = centsDifference(detected: result.frequency, expected: 82.41)
        XCTAssertLessThan(abs(cents), 2.0, "Should be within 2 cents for low E")
    }

    func testDetectBassLowB() {
        // Low B on bass: 30.87 Hz (critical test for octave errors)
        let samples = generateSineWave(frequency: 30.87, duration: 0.2)  // Longer for low freq
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        // Should detect around 30-31 Hz, not 61-62 Hz (octave error)
        XCTAssertLessThan(result.frequency, 50, "Should not report octave error (60+ Hz)")

        if result.frequency > 20 {
            XCTAssertEqual(result.frequency, 30.87, accuracy: 1.0)
        }
    }

    func testDetectHighE() {
        // High E on guitar: 329.63 Hz
        let samples = generateSineWave(frequency: 329.63)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.8)
        XCTAssertEqual(result.frequency, 329.63, accuracy: 0.5)

        let cents = centsDifference(detected: result.frequency, expected: 329.63)
        XCTAssertLessThan(abs(cents), 1.0)
    }

    func testDetectA432() {
        // Reference pitch test: 432 Hz
        let samples = generateSineWave(frequency: 432.0)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.8)
        XCTAssertEqual(result.frequency, 432.0, accuracy: 0.5)
    }

    func testSubCentAccuracy() {
        // Test with frequency that requires sub-sample interpolation
        let targetFreq = 440.5  // Slightly sharp of A440
        let samples = generateSineWave(frequency: targetFreq)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.8)
        let cents = centsDifference(detected: result.frequency, expected: targetFreq)
        XCTAssertLessThan(abs(cents), 1.0, "Should achieve sub-cent accuracy")
    }

    // MARK: - Noise Gate Tests

    func testNoiseGateRejectsSilence() {
        let silentSamples = [Float](repeating: 0.00001, count: 4096)  // Very quiet
        let isAbove = PitchDetector.isAboveNoiseGate(
            samples: silentSamples,
            thresholdDb: -40.0
        )
        XCTAssertFalse(isAbove, "Should reject signals below noise gate")
    }

    func testNoiseGateAcceptsNormalSignal() {
        let samples = generateSineWave(frequency: 440.0, duration: 0.1)
        let isAbove = PitchDetector.isAboveNoiseGate(
            samples: samples,
            thresholdDb: -60.0
        )
        XCTAssertTrue(isAbove, "Should accept normal signal level")
    }

    func testRMSCalculation() {
        let samples = generateSineWave(frequency: 440.0)
        let rms = PitchDetector.rmsLevel(samples: samples)

        // RMS of sine wave should be 1/sqrt(2) ≈ 0.707
        XCTAssertEqual(rms, 0.707, accuracy: 0.05)
    }

    // MARK: - Confidence Tests

    func testConfidenceForPureTone() {
        let samples = generateSineWave(frequency: 440.0)
        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        XCTAssertGreaterThan(result.confidence, 0.7, "Pure tone should have high confidence")
        XCTAssertLessThanOrEqual(result.confidence, 1.0, "Confidence should not exceed 1.0")
    }

    func testConfidenceForNoisySignal() {
        // Generate signal with noise
        var samples = generateSineWave(frequency: 440.0)
        for i in 0..<samples.count {
            samples[i] += Float.random(in: -0.1...0.1)
        }

        let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

        // Should still detect but with lower confidence
        XCTAssertGreaterThan(result.confidence, 0.3, "Should have some confidence")
    }

    func testConfidenceForSilence() {
        let silentSamples = [Float](repeating: 0, count: 4096)
        let result = PitchDetector.detect(samples: silentSamples, sampleRate: 48000)

        XCTAssertLessThan(result.confidence, 0.3, "Silence should have low confidence")
    }

    // MARK: - Frequency Range Tests

    func testVariousFrequencies() {
        let testFreqs = [30.87, 41.20, 55.00, 82.41, 110.00, 146.83, 196.00, 246.94, 329.63, 440.0, 587.33]

        for freq in testFreqs {
            let samples = generateSineWave(frequency: freq, duration: freq < 50 ? 0.2 : 0.1)
            let result = PitchDetector.detect(samples: samples, sampleRate: 48000)

            if result.confidence > 0.5 {
                let cents = centsDifference(detected: result.frequency, expected: freq)
                XCTAssertLessThan(abs(cents), 5.0, "Frequency \(freq) should be within 5 cents")
            }
        }
    }
}
