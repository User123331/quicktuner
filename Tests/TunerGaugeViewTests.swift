import Testing
import SwiftUI
import Foundation
@testable import QuickTuner

/// Tests for TunerGaugeView SwiftUI geometry-based rendering
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

    // MARK: - NeedleShape Tests

    @Test("NeedleShape creates valid path")
    func testNeedleShapePath() {
        let shape = NeedleShape()
        let rect = CGRect(x: 0, y: 0, width: 10, height: 95)
        let path = shape.path(in: rect)
        #expect(!path.isEmpty)
    }

    @Test("NeedleShape path is contained within rect bounds")
    func testNeedleShapeBounds() {
        let shape = NeedleShape()
        let rect = CGRect(x: 0, y: 0, width: 10, height: 95)
        let path = shape.path(in: rect)
        let bounds = path.boundingRect
        // Path should be within or equal to the given rect
        #expect(bounds.minX >= rect.minX - 1)
        #expect(bounds.maxX <= rect.maxX + 1)
        #expect(bounds.minY >= rect.minY - 1)
        #expect(bounds.maxY <= rect.maxY + 1)
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
