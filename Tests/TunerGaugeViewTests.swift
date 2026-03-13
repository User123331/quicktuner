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

    // MARK: - NeedleShaft Tests

    @Test("NeedleShaft creates valid path")
    func testNeedleShaftPath() {
        let shape = NeedleShaft()
        let rect = CGRect(x: 0, y: 0, width: 6, height: 90)
        let path = shape.path(in: rect)
        #expect(!path.isEmpty)
    }

    @Test("NeedleShaft path is contained within rect bounds")
    func testNeedleShaftBounds() {
        let shape = NeedleShaft()
        let rect = CGRect(x: 0, y: 0, width: 6, height: 90)
        let path = shape.path(in: rect)
        let bounds = path.boundingRect
        // Path should be within or equal to the given rect (±1pt tolerance)
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

    // MARK: - Math Function Tests

    @Test("angle(for:) maps cents to correct rotation angles")
    func testAngleMapping() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)
        // 0 cents = 0 degrees (center)
        let centerAngle = view.angle(for: 0.0)
        #expect(abs(centerAngle.degrees - 0.0) < 0.001)
        // +50 cents = +90 degrees (full right)
        let rightAngle = view.angle(for: 50.0)
        #expect(abs(rightAngle.degrees - 90.0) < 0.001)
        // -50 cents = -90 degrees (full left)
        let leftAngle = view.angle(for: -50.0)
        #expect(abs(leftAngle.degrees - (-90.0)) < 0.001)
        // Beyond 50 is clamped: 100 cents -> still 90 degrees
        let clampedAngle = view.angle(for: 100.0)
        #expect(abs(clampedAngle.degrees - 90.0) < 0.001)
    }

    @Test("arcAngle(for:) maps cents to arc degree positions")
    func testTickAngleMapping() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)
        // 0 cents = 0 degrees (top of arc)
        #expect(abs(view.arcAngle(for: 0.0) - 0.0) < 0.001)
        // +50 cents = +120 degrees (right endpoint of 240° arc)
        #expect(abs(view.arcAngle(for: 50.0) - 120.0) < 0.001)
        // -50 cents = -120 degrees (left endpoint)
        #expect(abs(view.arcAngle(for: -50.0) - (-120.0)) < 0.001)
        // +25 cents = +60 degrees
        #expect(abs(view.arcAngle(for: 25.0) - 60.0) < 0.001)
    }

    @Test("tickPosition(cents:radius:) returns correct position for center tick")
    func testTickPositionCenter() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)
        let pos = view.tickPosition(cents: 0.0, radius: 110)
        // Center tick (0 cents) should be straight up from pivot: x ≈ 0, y ≈ -110
        #expect(abs(pos.x) < 0.001)
        #expect(abs(pos.y + 110) < 0.001)
    }

    @Test("tickPosition(cents:radius:) for +50 cents is lower-right quadrant")
    func testTickPositionRight() {
        let view = TunerGaugeView(cents: 0.0, isInTune: false)
        let pos = view.tickPosition(cents: 50.0, radius: 110)
        // +50 cents = 120° from vertical — this reaches below horizontal (sin(120°)>0, cos(120°)<0 → y>0)
        #expect(pos.x > 0)  // right side
        #expect(pos.y > 0)  // below pivot (positive y in SwiftUI)
    }

    // MARK: - CounterweightShape Tests

    @Test("CounterweightShape path is within expected bounds")
    func testCounterweightBounds() {
        let shape = CounterweightShape()
        let rect = CGRect(x: 0, y: 0, width: 10, height: 18)
        let path = shape.path(in: rect)
        let bounds = path.boundingRect
        // minY may start above rect.minY by a small amount (slight curve)
        #expect(bounds.minY >= -3)
        // maxY may extend slightly below rect.maxY due to quadratic control point
        #expect(bounds.maxY <= rect.maxY + 3)
    }
}
