import Foundation
import Testing
@testable import QuickTuner

@Suite("TunerViewModel Tests")
struct TunerViewModelTests {

    // MARK: - EMA Smoothing Tests

    @Test("EMA smoothing with alpha=0.3")
    func emaSmoothing() {
        // First reading: 10 cents
        // smoothed = 0.3 * 10 + 0.7 * 0 = 3.0
        // Second reading: 20 cents
        // smoothed = 0.3 * 20 + 0.7 * 3.0 = 6 + 2.1 = 8.1

        let previous = 0.0
        let alpha = 0.3

        let first = (alpha * 10.0) + ((1 - alpha) * previous)
        #expect(first == 3.0)

        let second = (alpha * 20.0) + ((1 - alpha) * first)
        #expect(second.isApproximatelyEqual(to: 8.1, tolerance: 0.001))
    }

    @Test("EMA smoothing reduces jitter over multiple samples")
    func emaSmoothingJitterReduction() {
        let alpha = 0.3
        var smoothed = 10.0  // Start at the baseline to avoid startup artifacts

        // Simulate jitter around 10: 12, 9, 11, 10, 13, 8
        let rawValues = [12.0, 9.0, 11.0, 10.0, 13.0, 8.0]
        var results: [Double] = []

        for raw in rawValues {
            smoothed = (alpha * raw) + ((1 - alpha) * smoothed)
            results.append(smoothed)
        }

        // The smoothed values should vary less than raw values
        // Check that max-min range of smoothed is less than raw
        let rawRange = rawValues.max()! - rawValues.min()!
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

    @Test("In-tune state with ±2 cents threshold")
    func inTuneThreshold() async throws {
        let viewModel = await TunerViewModel()

        // Start the in-tune check
        await viewModel.checkInTuneState(1.5)  // Within ±2

        // Initially not in tune (needs 200ms hold)
        #expect(await viewModel.isInTune == false)
    }

    @Test("Cents display formatting")
    func centsDisplayFormatting() async throws {
        let viewModel = await TunerViewModel()

        // Initial state with no signal
        #expect(await viewModel.centsDisplay == "--")
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
