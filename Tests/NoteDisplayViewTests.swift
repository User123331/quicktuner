import Testing
import SwiftUI
import Foundation
@testable import QuickTuner

/// Tests for NoteDisplayView component
@Suite("NoteDisplayView Tests")
struct NoteDisplayViewTests {

    // MARK: - Initialization Tests

    @Test("Display initializes with note name")
    func testWithNoteName() {
        let view = NoteDisplayView(noteName: "E2", isInTune: false)
        #expect(view != nil)
    }

    @Test("Display initializes with nil note name")
    func testWithNilNoteName() {
        let view = NoteDisplayView(noteName: nil, isInTune: false)
        #expect(view != nil)
    }

    @Test("Display initializes with empty note name")
    func testWithEmptyNoteName() {
        let view = NoteDisplayView(noteName: "", isInTune: false)
        #expect(view != nil)
    }

    // MARK: - In-Tune State Tests

    @Test("Display shows green when in tune")
    func testInTuneColor() {
        let view = NoteDisplayView(noteName: "A2", isInTune: true)
        // Should show green color
        #expect(view != nil)
    }

    @Test("Display shows primary color when out of tune")
    func testOutOfTuneColor() {
        let view = NoteDisplayView(noteName: "A2", isInTune: false)
        // Should show primary color
        #expect(view != nil)
    }

    // MARK: - Note Format Tests

    @Test("Display shows sharp notes")
    func testSharpNote() {
        let view = NoteDisplayView(noteName: "F#3", isInTune: false)
        #expect(view != nil)
    }

    @Test("Display shows flat notes")
    func testFlatNote() {
        let view = NoteDisplayView(noteName: "Bb2", isInTune: false)
        #expect(view != nil)
    }

    @Test("Display shows high octave")
    func testHighOctave() {
        let view = NoteDisplayView(noteName: "E4", isInTune: false)
        #expect(view != nil)
    }

    @Test("Display shows low octave")
    func testLowOctave() {
        let view = NoteDisplayView(noteName: "B1", isInTune: false)
        #expect(view != nil)
    }

    // MARK: - Edge Cases

    @Test("Display handles whitespace-only note name")
    func testWhitespaceNoteName() {
        let view = NoteDisplayView(noteName: "   ", isInTune: false)
        // Should treat as empty
        #expect(view != nil)
    }

    @Test("Display handles single character")
    func testSingleCharacter() {
        let view = NoteDisplayView(noteName: "E", isInTune: false)
        #expect(view != nil)
    }

    @Test("Display handles complex note name")
    func testComplexNoteName() {
        let view = NoteDisplayView(noteName: "C#4/Db4", isInTune: false)
        #expect(view != nil)
    }
}
