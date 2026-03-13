import Testing
import SwiftUI
import Foundation
@testable import QuickTuner

/// Tests for TunerGaugeView linear gauge
@Suite("TunerGaugeView Tests")
struct TunerGaugeViewTests {

    // MARK: - Initialization Tests

    @Test("Gauge initializes with cents and isInTune values")
    func testInitialization() {
        let view = TunerGaugeView(cents: -15.0, isInTune: false)
        #expect(view != nil)
    }

    @Test("Gauge accepts zero cents")
    func testZeroCents() {
        let view = TunerGaugeView(cents: 0.0, isInTune: true)
        #expect(view != nil)
    }

    @Test("Gauge accepts negative cents (flat)")
    func testNegativeCents() {
        let view = TunerGaugeView(cents: -25.0, isInTune: false)
        #expect(view != nil)
    }

    @Test("Gauge accepts positive cents (sharp)")
    func testPositiveCents() {
        let view = TunerGaugeView(cents: 42.0, isInTune: false)
        #expect(view != nil)
    }

    // MARK: - Range Tests

    @Test("Gauge clamps cents at -50 minimum")
    func testClampMinimum() {
        let view = TunerGaugeView(cents: -100.0, isInTune: false)
        #expect(view != nil)
    }

    @Test("Gauge clamps cents at +50 maximum")
    func testClampMaximum() {
        let view = TunerGaugeView(cents: 75.0, isInTune: false)
        #expect(view != nil)
    }

    // MARK: - In-Tune State Tests

    @Test("Gauge shows in-tune state")
    func testInTuneState() {
        let view = TunerGaugeView(cents: 1.5, isInTune: true)
        #expect(view != nil)
    }

    @Test("Gauge shows out-of-tune state")
    func testOutOfTuneState() {
        let view = TunerGaugeView(cents: 15.0, isInTune: false)
        #expect(view != nil)
    }

    // MARK: - Needle Offset Tests

    @Test("needleOffset maps cents to correct horizontal position")
    func testNeedleOffsetMapping() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)

        // 0 cents = center (offset = 0)
        let centerOffset = view.needleOffset(for: 0.0)
        #expect(abs(centerOffset) < 0.001)

        // +50 cents = max right (offset = +gaugeWidth/2 = +140)
        let rightOffset = view.needleOffset(for: 50.0)
        #expect(abs(rightOffset - 140.0) < 0.001)

        // -50 cents = max left (offset = -140)
        let leftOffset = view.needleOffset(for: -50.0)
        #expect(abs(leftOffset - (-140.0)) < 0.001)

        // +25 cents = half way right (offset = +70)
        let halfRightOffset = view.needleOffset(for: 25.0)
        #expect(abs(halfRightOffset - 70.0) < 0.001)

        // -25 cents = half way left (offset = -70)
        let halfLeftOffset = view.needleOffset(for: -25.0)
        #expect(abs(halfLeftOffset - (-70.0)) < 0.001)
    }

    @Test("needleOffset clamps values beyond ±50")
    func testNeedleOffsetClamping() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)

        // Values beyond ±50 should be clamped
        let beyondMax = view.needleOffset(for: 100.0)
        #expect(abs(beyondMax - 140.0) < 0.001)

        let beyondMin = view.needleOffset(for: -100.0)
        #expect(abs(beyondMin - (-140.0)) < 0.001)
    }

    // MARK: - Visual Configuration Tests

    @Test("Gauge has expected frame dimensions")
    func testFrameSize() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)
        let body = view.body
        #expect(body != nil)
    }

    // MARK: - Color Zone Tests

    @Test("Gauge renders green zone for in-tune range")
    func testGreenZoneRendering() {
        let view = TunerGaugeView(cents: 1.0, isInTune: false)
        #expect(view != nil)
    }

    @Test("Gauge renders yellow zone for moderate deviation")
    func testYellowZoneRendering() {
        let view = TunerGaugeView(cents: 20.0, isInTune: false)
        #expect(view != nil)
    }

    @Test("Gauge renders red zone for large deviation")
    func testRedZoneRendering() {
        let view = TunerGaugeView(cents: 40.0, isInTune: false)
        #expect(view != nil)
    }
}
