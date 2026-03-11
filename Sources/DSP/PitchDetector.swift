import Foundation
import Accelerate

enum PitchDetector {

    /// Detect pitch from audio samples using YIN algorithm
    /// - Parameters:
    ///   - samples: Audio buffer (mono, float)
    ///   - sampleRate: Sample rate in Hz (e.g., 48000)
    /// - Returns: PitchResult with frequency and confidence
    static func detect(samples: [Float], sampleRate: Double) -> PitchResult {
        // Step 1: Difference function
        let diff = differenceFunction(samples: samples)

        // Step 2: Cumulative Mean Normalized Difference
        let cmnd = cumulativeMeanNormalizedDifference(diff: diff)

        // Step 3: Absolute threshold search
        let (tau, confidence) = absoluteThresholdSearch(cmnd: cmnd, sampleRate: sampleRate)

        // Step 4: Parabolic interpolation for fractional lag
        let fractionalTau = parabolicInterpolation(cmnd: cmnd, tau: tau)

        // Step 5: Convert lag to frequency
        if fractionalTau > 0 {
            let frequency = sampleRate / fractionalTau
            return PitchResult(frequency: frequency, confidence: confidence)
        } else {
            return PitchResult(frequency: 0, confidence: 0)
        }
    }

    // MARK: - YIN Algorithm Steps

    /// Step 1: Difference function using vDSP
    /// d[tau] = sum((x[t] - x[t+tau])^2) for t = 0 to N-tau-1
    private static func differenceFunction(samples: [Float]) -> [Float] {
        let n = samples.count
        let maxTau = n / 2  // Only need to check up to half the buffer
        var diff = [Float](repeating: 0, count: maxTau)

        // Pre-allocate working buffer
        var temp = [Float](repeating: 0, count: n)

        for tau in 1..<maxTau {
            let count = n - tau

            // temp[t] = samples[t] - samples[t+tau]
            samples.withUnsafeBufferPointer { samplePtr in
                temp.withUnsafeMutableBufferPointer { tempPtr in
                    let x1 = samplePtr.baseAddress!
                    let x2 = samplePtr.baseAddress!.advanced(by: tau)
                    let out = tempPtr.baseAddress!

                    // x[t] - x[t+tau]
                    vDSP_vsub(x2, 1, x1, 1, out, 1, vDSP_Length(count))

                    // sum of squares
                    var sum: Float = 0
                    vDSP_svesq(out, 1, &sum, vDSP_Length(count))
                    diff[tau] = sum
                }
            }
        }

        return diff
    }

    /// Step 2: Cumulative Mean Normalized Difference
    /// CMND[tau] = diff[tau] / ((1/tau) * sum(diff[1..tau]))
    private static func cumulativeMeanNormalizedDifference(diff: [Float]) -> [Float] {
        let maxTau = diff.count
        var cmnd = [Float](repeating: 1, count: maxTau)  // Start at 1 (normalized)
        cmnd[0] = 1  // tau=0 is undefined, set to 1

        var runningSum: Float = 0

        for tau in 1..<maxTau {
            runningSum += diff[tau]
            let mean = runningSum / Float(tau)
            if mean > 0 {
                cmnd[tau] = diff[tau] / mean
            } else {
                cmnd[tau] = 1  // Avoid division by zero
            }
        }

        return cmnd
    }

    // MARK: - Threshold and Interpolation

    /// Step 3: Absolute threshold search
    /// Find first tau where CMND[tau] < threshold
    /// Returns (period, confidence) where confidence is 1 - CMND[tau]
    private static func absoluteThresholdSearch(
        cmnd: [Float],
        sampleRate: Double
    ) -> (tau: Int, confidence: Double) {

        // Calculate min/max period from frequency range
        let minPeriod = Int(sampleRate / YINConfig.maxFrequency)
        let maxPeriod = min(Int(sampleRate / YINConfig.minFrequency), cmnd.count - 1)

        var bestTau = 0
        var minValue: Float = Float.greatestFiniteMagnitude

        // Search for first dip below threshold (YIN step 3)
        for tau in minPeriod..<maxPeriod {
            // Check if below threshold
            if cmnd[tau] < Float(YINConfig.minThreshold) {
                // Found a dip below threshold - now look for local minimum
                // by checking if it starts rising again
                if tau + 1 < cmnd.count && cmnd[tau] < cmnd[tau + 1] {
                    bestTau = tau
                    minValue = cmnd[tau]
                    break
                }
            }
        }

        // If no threshold crossing found, use global minimum as fallback
        if bestTau == 0 {
            for tau in minPeriod..<maxPeriod {
                if cmnd[tau] < minValue {
                    minValue = cmnd[tau]
                    bestTau = tau
                }
            }
        }

        // Confidence based on CMND value (lower is better)
        // 1.0 = perfect periodicity, 0.0 = no periodicity
        let confidence = (bestTau > 0) ? Double(1.0 - minValue) : 0.0

        return (bestTau, confidence)
    }

    /// Step 4: Parabolic interpolation around minimum for sub-sample accuracy
    /// Returns fractional tau value
    private static func parabolicInterpolation(cmnd: [Float], tau: Int) -> Double {
        guard tau > 0 && tau < cmnd.count - 1 else {
            return Double(tau)
        }

        let alpha = Double(cmnd[tau - 1])
        let beta = Double(cmnd[tau])
        let gamma = Double(cmnd[tau + 1])

        // Parabolic interpolation formula
        // p = (alpha - gamma) / (2 * (alpha - 2*beta + gamma))
        let denominator = 2.0 * (alpha - 2.0 * beta + gamma)

        if abs(denominator) < 1e-10 {
            return Double(tau)  // Avoid division by near-zero
        }

        let p = (alpha - gamma) / denominator
        return Double(tau) + p
    }

    /// Calculate RMS level for noise gating
    static func rmsLevel(samples: [Float]) -> Float {
        var rms: Float = 0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(samples.count))
        return rms
    }

    /// Convert RMS to decibels
    static func rmsToDecibels(rms: Float) -> Float {
        return 20 * log10(max(rms, 0.00001))  // Prevent log(0)
    }

    /// Check if signal is above noise gate threshold
    static func isAboveNoiseGate(samples: [Float], thresholdDb: Float) -> Bool {
        let rms = rmsLevel(samples: samples)
        let db = rmsToDecibels(rms: rms)
        return db > thresholdDb
    }
}
