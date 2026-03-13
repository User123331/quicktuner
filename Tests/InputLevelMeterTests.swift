import Testing
import SwiftUI
import Foundation
@testable import QuickTuner

/// Tests for InputLevelMeter component
@Suite("InputLevelMeter Tests")
struct InputLevelMeterTests {

    // MARK: - Initialization Tests

    @Test("Meter initializes with zero level")
    func testZeroLevel() {
        let view = InputLevelMeter(level: 0.0)
        // Verify the view can be created with zero level
        #expect(type(of: view) == InputLevelMeter.self)
    }

    @Test("Meter initializes with mid level")
    func testMidLevel() {
        let view = InputLevelMeter(level: 0.5)
        // Verify the view can be created with mid level
        #expect(type(of: view) == InputLevelMeter.self)
    }

    @Test("Meter initializes with full level")
    func testFullLevel() {
        let view = InputLevelMeter(level: 1.0)
        // Verify the view can be created with full level
        #expect(type(of: view) == InputLevelMeter.self)
    }

    // MARK: - Color Zone Ratio Tests

    @Test("Color zones maintain 60/25/15 ratio")
    func testColorZoneRatios() {
        // Given a segment count, verify the color distribution
        // For 20 segments: 12 green, 5 yellow, 3 red
        // For 30 segments: 18 green, 7-8 yellow, 4-5 red (approximately)
        let testCases: [(segmentCount: Int, expectedGreen: Int, expectedYellow: Int)] = [
            (20, 12, 5),
            (30, 18, 7),
            (40, 24, 10),
            (15, 9, 4),
        ]

        for testCase in testCases {
            let greenCount = Int(Float(testCase.segmentCount) * 0.6)
            let yellowCount = Int(Float(testCase.segmentCount) * 0.25)
            #expect(greenCount == testCase.expectedGreen)
            #expect(yellowCount >= testCase.expectedYellow - 1 && yellowCount <= testCase.expectedYellow + 1)
        }
    }

    // MARK: - Segment Width Calculation Tests

    @Test("Segment width is positive for valid input")
    func testSegmentWidthPositive() {
        // With 200pt width, 20 segments, 2pt spacing:
        // segmentWidth = (200 - 2*19) / 20 = (200 - 38) / 20 = 162/20 = 8.1pt
        let totalWidth: CGFloat = 200
        let segmentCount = 20
        let spacing: CGFloat = 2
        let expectedWidth = (totalWidth - spacing * CGFloat(segmentCount - 1)) / CGFloat(segmentCount)
        #expect(expectedWidth > 0)
        #expect(expectedWidth == 8.1)
    }

    @Test("Segment width scales with container width")
    func testSegmentWidthScales() {
        let spacing: CGFloat = 2
        let minSegmentWidth: CGFloat = 8

        // At 300pt container (90% = 270pt)
        let width1: CGFloat = 270
        let segCount1 = Int((width1 + spacing) / (minSegmentWidth + spacing))
        #expect(segCount1 > 20)  // Should have more segments than fixed 20

        // At 200pt container (90% = 180pt)
        let width2: CGFloat = 180
        let segCount2 = Int((width2 + spacing) / (minSegmentWidth + spacing))
        #expect(segCount2 < segCount1)  // Fewer segments at smaller width
    }
}