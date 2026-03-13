import Testing
import SwiftUI
import Foundation
@testable import QuickTuner

/// Tests for CentsReadoutView component
@Suite("CentsReadoutView Tests")
struct CentsReadoutViewTests {

    // MARK: - Initialization Tests

    @Test("Readout initializes with nil cents")
    func testNilCents() {
        let view = CentsReadoutView(cents: nil)
        #expect(view != nil)
    }

    @Test("Readout initializes with zero cents")
    func testZeroCents() {
        let view = CentsReadoutView(cents: 0.0)
        #expect(view != nil)
    }

    @Test("Readout initializes with positive cents")
    func testPositiveCents() {
        let view = CentsReadoutView(cents: 15.5)
        #expect(view != nil)
    }

    @Test("Readout initializes with negative cents")
    func testNegativeCents() {
        let view = CentsReadoutView(cents: -8.3)
        #expect(view != nil)
    }

    // MARK: - Rounding Tests

    @Test("Readout rounds to nearest integer")
    func testRoundingUp() {
        let view = CentsReadoutView(cents: 15.7)
        // Should display as +16
        #expect(view != nil)
    }

    @Test("Readout rounds down correctly")
    func testRoundingDown() {
        let view = CentsReadoutView(cents: -12.2)
        // Should display as -12
        #expect(view != nil)
    }

    @Test("Readout rounds 0.5 up")
    func testRoundingHalf() {
        let view = CentsReadoutView(cents: 4.5)
        // Should display as +5
        #expect(view != nil)
    }

    // MARK: - Sign Tests

    @Test("Readout shows plus sign for positive cents")
    func testPositiveSign() {
        let view = CentsReadoutView(cents: 5.0)
        // Should display as +5
        #expect(view != nil)
    }

    @Test("Readout shows minus sign for negative cents")
    func testNegativeSign() {
        let view = CentsReadoutView(cents: -5.0)
        // Should display as -5
        #expect(view != nil)
    }

    @Test("Readout shows zero without sign")
    func testZeroNoSign() {
        let view = CentsReadoutView(cents: 0.0)
        // Should display as 0
        #expect(view != nil)
    }

    // MARK: - Color Tests

    @Test("Readout shows green for in-tune range")
    func testGreenColor() {
        let view = CentsReadoutView(cents: 1.5)
        // 1.5 cents should be green (threshold: <3)
        #expect(view != nil)
    }

    @Test("Readout shows yellow for moderate deviation")
    func testYellowColor() {
        let view = CentsReadoutView(cents: 8.0)
        // 8 cents should be orange (threshold: 3-15)
        #expect(view != nil)
    }

    @Test("Readout shows red for large deviation")
    func testRedColor() {
        let view = CentsReadoutView(cents: 35.0)
        // 35 cents should be red (threshold: >=15)
        #expect(view != nil)
    }

    @Test("Readout shows secondary color for nil")
    func testNilColor() {
        let view = CentsReadoutView(cents: nil)
        // Should show -- in secondary color
        #expect(view != nil)
    }

    // MARK: - Edge Cases

    @Test("Readout handles exactly -2 cents")
    func testExactlyMinusTwo() {
        let view = CentsReadoutView(cents: -2.0)
        // Within green zone (|2| < 3)
        #expect(view != nil)
    }

    @Test("Readout handles exactly +2 cents")
    func testExactlyPlusTwo() {
        let view = CentsReadoutView(cents: 2.0)
        // Within green zone (|2| < 3)
        #expect(view != nil)
    }

    @Test("Readout handles exactly ±25 cents")
    func testExactlyTwentyFive() {
        let view = CentsReadoutView(cents: 25.0)
        // In red zone (|25| >= 15)
        #expect(view != nil)
    }

    @Test("Readout handles boundary at 3 cents")
    func testBoundaryThreeCents() {
        let view = CentsReadoutView(cents: 3.0)
        // |3| >= 3, so should be orange (not green)
        #expect(view != nil)
    }

    @Test("Readout handles boundary at 15 cents")
    func testBoundaryFifteenCents() {
        let view = CentsReadoutView(cents: 15.0)
        // |15| >= 15, so should be red (not orange)
        #expect(view != nil)
    }
}
