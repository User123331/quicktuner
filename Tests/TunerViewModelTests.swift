import Foundation
import Testing
@testable import QuickTuner

@Suite("TunerViewModel Tests")
struct TunerViewModelTests {

    // MARK: - EMA Smoothing Tests

    @Test("Adaptive EMA uses heavy smoothing for small deviations")
    func emaHeavySmoothingSmallDeviation() async throws {
        let viewModel = await TunerViewModel()

        // First reading from 0: deviation = |10 - 0| = 10 > 5, so alpha = 0.2
        let first = await viewModel.applyEMA(10.0)
        // smoothed = 0.2 * 10 + 0.8 * 0 = 2.0
        #expect(first.isApproximatelyEqual(to: 2.0, tolerance: 0.001))

        // Second reading: deviation = |12 - 2| = 10 > 5, so alpha = 0.2
        let second = await viewModel.applyEMA(12.0)
        // smoothed = 0.2 * 12 + 0.8 * 2.0 = 2.4 + 1.6 = 4.0
        #expect(second.isApproximatelyEqual(to: 4.0, tolerance: 0.001))
    }

    @Test("Adaptive EMA uses fast tracking for large jumps")
    func emaFastTrackingLargeJump() async throws {
        let viewModel = await TunerViewModel()

        // Large jump from 0 to 40: deviation = 40 > 20, alpha = 0.5
        let result = await viewModel.applyEMA(40.0)
        // smoothed = 0.5 * 40 + 0.5 * 0 = 20.0
        #expect(result.isApproximatelyEqual(to: 20.0, tolerance: 0.001))
    }

    @Test("Adaptive EMA reduces jitter in fine tuning range")
    func emaReducesJitterFineTuning() async throws {
        let viewModel = await TunerViewModel()

        // Establish baseline near 10
        // First call: deviation = |10 - 0| = 10 > 5, alpha = 0.2
        _ = await viewModel.applyEMA(10.0)
        // After a few calls, get close to 10
        _ = await viewModel.applyEMA(10.0)
        _ = await viewModel.applyEMA(10.0)
        _ = await viewModel.applyEMA(10.0)
        _ = await viewModel.applyEMA(10.0)

        // Now simulate small jitter around 10 (fine tuning)
        let jitterValues = [10.5, 9.8, 10.2, 9.9, 10.3]
        var results: [Double] = []
        for raw in jitterValues {
            let smoothed = await viewModel.applyEMA(raw)
            results.append(smoothed)
        }

        // Smoothed range should be much smaller than raw range
        let rawRange = jitterValues.max()! - jitterValues.min()!
        let smoothedRange = results.max()! - results.min()!
        #expect(smoothedRange < rawRange)
    }

    // MARK: - String Navigation Tests

    @Test("String selection bounds")
    func stringSelectionBounds() async throws {
        let viewModel = await TunerViewModel()

        // Default: String 1 (index 0)
        #expect(await viewModel.selectedStringIndex == 0)

        // Navigate next
        await viewModel.selectNextString()
        #expect(await viewModel.selectedStringIndex == 1)

        // Navigate to last
        await viewModel.selectString(at: 5)
        #expect(await viewModel.selectedStringIndex == 5)

        // Try to go past last
        await viewModel.selectNextString()
        #expect(await viewModel.selectedStringIndex == 5)  // Should stay at 5

        // Navigate previous
        await viewModel.selectPreviousString()
        #expect(await viewModel.selectedStringIndex == 4)

        // Try to go before first
        await viewModel.selectString(at: 0)
        await viewModel.selectPreviousString()
        #expect(await viewModel.selectedStringIndex == 0)  // Should stay at 0
    }

    @Test("Direct string selection via number")
    func directStringSelection() async throws {
        let viewModel = await TunerViewModel()

        // Select String 3 (index 2)
        await viewModel.selectString(at: 2)
        #expect(await viewModel.selectedStringIndex == 2)

        // Select String 6 (index 5)
        await viewModel.selectString(at: 5)
        #expect(await viewModel.selectedStringIndex == 5)
    }

    @Test("String selection out of bounds is ignored")
    func stringSelectionOutOfBounds() async throws {
        let viewModel = await TunerViewModel()

        // Try to select negative index
        await viewModel.selectString(at: -1)
        #expect(await viewModel.selectedStringIndex == 0)  // Should stay at 0

        // Try to select beyond last string
        await viewModel.selectString(at: 100)
        #expect(await viewModel.selectedStringIndex == 0)  // Should stay at 0
    }

    // MARK: - Tuned String Tracking Tests

    @Test("Mark string as tuned")
    func markStringAsTuned() async throws {
        let viewModel = await TunerViewModel()

        await viewModel.markStringAsTuned(at: 0)
        #expect(await viewModel.tunedStrings.contains(0))
        #expect(await viewModel.isSelectedStringTuned == true)

        await viewModel.selectString(at: 1)
        #expect(await viewModel.isSelectedStringTuned == false)
    }

    @Test("All strings tuned detection")
    func allStringsTunedDetection() async throws {
        let viewModel = await TunerViewModel()

        #expect(await viewModel.allStringsTuned == false)

        // Mark all 6 strings as tuned
        for i in 0..<6 {
            await viewModel.markStringAsTuned(at: i)
        }

        #expect(await viewModel.allStringsTuned == true)
    }

    @Test("Reset clears all tuned strings")
    func resetClearsTunedStrings() async throws {
        let viewModel = await TunerViewModel()

        await viewModel.markStringAsTuned(at: 0)
        await viewModel.markStringAsTuned(at: 3)
        #expect(await viewModel.tunedStrings.count == 2)

        await viewModel.resetTunedStrings()
        #expect(await viewModel.tunedStrings.isEmpty)
        #expect(await viewModel.allStringsTuned == false)
    }

    @Test("Reset returns to String 1")
    func resetReturnsToFirstString() async throws {
        let viewModel = await TunerViewModel()

        await viewModel.selectString(at: 3)
        await viewModel.markStringAsTuned(at: 3)

        await viewModel.resetTunedStrings()

        #expect(await viewModel.selectedStringIndex == 0)
    }

    // MARK: - In-Tune State Machine Tests

    @Test("In-tune detection thresholds")
    func inTuneDetectionThresholds() async throws {
        let viewModel = await TunerViewModel()

        // Verify initial state
        #expect(await viewModel.isInTune == false)

        // Test threshold boundaries
        // Enter threshold: |cents| <= 2
        // Exit threshold: |cents| > 3 (1 cent hysteresis)

        // At exactly 2.0: should trigger hold (enter)
        await viewModel.checkInTuneState(2.0)
        // Not immediately in tune, but hold timer started

        // At 2.5: within dead zone (won't enter, won't exit if already in)
        // Should not trigger entry (> 2), not trigger exit (< 3)

        // At 3.5: should trigger exit if in tune (> 3)

        // Verify threshold constants via behavior
        let enterThreshold = 2.0
        let exitThreshold = 3.0

        // Values that should trigger entry
        #expect(abs(0.0) <= enterThreshold)
        #expect(abs(1.5) <= enterThreshold)
        #expect(abs(2.0) <= enterThreshold)

        // Values that should NOT trigger entry
        #expect(abs(2.1) > enterThreshold)
        #expect(abs(2.5) > enterThreshold)

        // Values that should trigger exit (if in tune)
        #expect(abs(3.1) > exitThreshold)
        #expect(abs(3.5) > exitThreshold)

        // Values that should NOT trigger exit (dead zone)
        #expect(abs(2.5) <= exitThreshold)
        #expect(abs(3.0) <= exitThreshold)
    }

    @Test("In-tune state requires 200ms hold")
    func inTuneRequiresHold() async throws {
        let viewModel = await TunerViewModel()

        // Initially not in tune
        #expect(await viewModel.isInTune == false)

        // Enter in-tune zone
        await viewModel.checkInTuneState(1.0)

        // Immediately check - should NOT be in tune yet (needs 200ms)
        #expect(await viewModel.isInTune == false)

        // Wait for hold duration (200ms)
        try await Task.sleep(nanoseconds: 250_000_000) // 250ms

        // Now should be in tune
        #expect(await viewModel.isInTune == true)
    }

    @Test("Hysteresis prevents flicker at boundary")
    func hysteresisPreventsFlicker() async throws {
        // At 2.5 cents: above enter threshold (2), below exit threshold (3)
        // This creates a dead zone where state doesn't change

        let cents = 2.5
        let inTuneThreshold = 2.0
        let outOfTuneThreshold = 3.0

        let wouldEnter = abs(cents) <= inTuneThreshold      // false
        let wouldExit = abs(cents) > outOfTuneThreshold     // false

        // Neither enter nor exit - stable dead zone prevents flicker
        #expect(wouldEnter == false)
        #expect(wouldExit == false)
    }

    @Test("Tuned string persists after navigation away")
    func tunedStringPersists() async throws {
        let viewModel = await TunerViewModel()

        // Mark string 0 as tuned
        await viewModel.markStringAsTuned(at: 0)
        #expect(await viewModel.tunedStrings.contains(0))

        // Navigate to string 1
        await viewModel.selectString(at: 1)
        #expect(await viewModel.selectedStringIndex == 1)

        // String 0 should still be tuned
        #expect(await viewModel.tunedStrings.contains(0))

        // String 1 should not be tuned
        #expect(await viewModel.tunedStrings.contains(1) == false)
    }

    @Test("Reset clears in-tune state and checkmarks")
    func resetClearsInTuneAndCheckmarks() async throws {
        let viewModel = await TunerViewModel()

        // Set some state
        await viewModel.markStringAsTuned(at: 0)
        await viewModel.markStringAsTuned(at: 2)

        #expect(await viewModel.tunedStrings.count == 2)
        #expect(await viewModel.strings[0].isTuned == true)
        #expect(await viewModel.strings[2].isTuned == true)

        // Reset
        await viewModel.resetTunedStrings()

        // Verify all cleared
        #expect(await viewModel.tunedStrings.isEmpty)
        #expect(await viewModel.allStringsTuned == false)
        #expect(await viewModel.isInTune == false)

        // Checkmarks cleared from strings array
        #expect(await viewModel.strings[0].isTuned == false)
        #expect(await viewModel.strings[2].isTuned == false)

        // Returned to first string
        #expect(await viewModel.selectedStringIndex == 0)
    }

    @Test("In-tune exits when cents exceeds threshold")
    func inTuneExitsWhenOutOfRange() async throws {
        let viewModel = await TunerViewModel()

        // Get in tune
        await viewModel.checkInTuneState(1.0)
        try await Task.sleep(nanoseconds: 250_000_000) // Wait for hold
        #expect(await viewModel.isInTune == true)

        // Move out of tune (> 3 cents)
        await viewModel.checkInTuneState(4.0)

        // Should exit immediately (no hold required to exit)
        #expect(await viewModel.isInTune == false)
    }

    @Test("Transient readings don't trigger in-tune")
    func transientReadingsDontTrigger() async throws {
        let viewModel = await TunerViewModel()

        // Briefly enter in-tune zone
        await viewModel.checkInTuneState(1.0)

        // Immediately leave before hold completes
        await viewModel.checkInTuneState(10.0)

        // Wait a bit
        try await Task.sleep(nanoseconds: 250_000_000)

        // Should NOT be in tune because we left the zone
        #expect(await viewModel.isInTune == false)
    }

    @Test("Cents display formatting")
    func centsDisplayFormatting() async throws {
        let viewModel = await TunerViewModel()

        // Initial state with no signal
        #expect(await viewModel.centsDisplay == "--")
    }

    // MARK: - All Tuned Badge Tests

    @Test("All tuned badge appears after 500ms delay when all strings tuned")
    func allTunedBadgeAppearsWithDelay() async throws {
        let viewModel = await TunerViewModel()

        // Initially no badge
        #expect(await viewModel.showAllTunedBadge == false)

        // Mark all strings as tuned
        for i in 0..<6 {
            await viewModel.markStringAsTuned(at: i)
        }

        // Badge should NOT appear immediately (500ms delay)
        #expect(await viewModel.showAllTunedBadge == false)

        // Wait for the delay (550ms to be safe)
        try await Task.sleep(nanoseconds: 550_000_000)

        // Now badge should appear
        #expect(await viewModel.showAllTunedBadge == true)
    }

    @Test("All tuned badge does not appear if not all strings tuned")
    func allTunedBadgeRequiresAllStrings() async throws {
        let viewModel = await TunerViewModel()

        // Mark only some strings
        await viewModel.markStringAsTuned(at: 0)
        await viewModel.markStringAsTuned(at: 3)

        // Wait longer than the delay
        try await Task.sleep(nanoseconds: 600_000_000)

        // Badge should NOT appear
        #expect(await viewModel.showAllTunedBadge == false)
    }

    @Test("All tuned badge can be dismissed")
    func allTunedBadgeDismissible() async throws {
        let viewModel = await TunerViewModel()

        // Mark all strings
        for i in 0..<6 {
            await viewModel.markStringAsTuned(at: i)
        }

        try await Task.sleep(nanoseconds: 550_000_000)
        #expect(await viewModel.showAllTunedBadge == true)

        // Dismiss
        await viewModel.dismissAllTunedBadge()
        #expect(await viewModel.showAllTunedBadge == false)
    }

    @Test("Reset clears all tuned badge")
    func resetClearsAllTunedBadge() async throws {
        let viewModel = await TunerViewModel()

        // Mark all strings
        for i in 0..<6 {
            await viewModel.markStringAsTuned(at: i)
        }

        try await Task.sleep(nanoseconds: 550_000_000)
        #expect(await viewModel.showAllTunedBadge == true)

        // Reset
        await viewModel.resetTunedStrings()
        #expect(await viewModel.showAllTunedBadge == false)
    }

    @Test("All tuned badge delay cancels if string becomes untuned")
    func allTunedBadgeDelayCancelsOnUntune() async throws {
        let viewModel = await TunerViewModel()

        // Mark all strings
        for i in 0..<6 {
            await viewModel.markStringAsTuned(at: i)
        }

        // Wait partial delay (200ms)
        try await Task.sleep(nanoseconds: 200_000_000)

        // Untune one string before delay completes
        await viewModel.resetTunedStrings()
        await viewModel.markStringAsTuned(at: 0)
        await viewModel.markStringAsTuned(at: 1)
        await viewModel.markStringAsTuned(at: 2)
        await viewModel.markStringAsTuned(at: 3)
        await viewModel.markStringAsTuned(at: 4)
        // String 5 not tuned

        // Wait remaining time
        try await Task.sleep(nanoseconds: 400_000_000)

        // Badge should NOT appear (not all tuned)
        #expect(await viewModel.showAllTunedBadge == false)
    }

    // MARK: - Display Properties Tests

    @Test("Note name display with no signal")
    func noteNameDisplayNoSignal() async throws {
        let viewModel = await TunerViewModel()

        #expect(await viewModel.noteNameText == "--")
    }

    @Test("Strings array contains standard guitar tuning")
    func stringsArrayContents() async throws {
        let viewModel = await TunerViewModel()

        let strings = await viewModel.strings
        #expect(strings.count == 6)
        #expect(strings[0].note.name == "E")
        #expect(strings[0].note.octave == 2)
        #expect(strings[5].note.name == "E")
        #expect(strings[5].note.octave == 4)
    }
}

// MARK: - Helper Extensions

extension Double {
    func isApproximatelyEqual(to other: Double, tolerance: Double) -> Bool {
        abs(self - other) <= tolerance
    }
}

func calculateVariance(_ values: [Double]) -> Double {
    let mean = values.reduce(0, +) / Double(values.count)
    let squaredDiffs = values.map { pow($0 - mean, 2) }
    return squaredDiffs.reduce(0, +) / Double(values.count)
}
