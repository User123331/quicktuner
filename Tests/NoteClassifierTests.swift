import XCTest
@testable import QuickTuner

final class NoteClassifierTests: XCTestCase {

    // MARK: - Reference Pitch 440 Hz Tests

    func testClassifyA440() {
        let note = NoteClassifier.classify(frequency: 440.0, referencePitch: 440.0)
        XCTAssertEqual(note.name, "A")
        XCTAssertEqual(note.octave, 4)
        XCTAssertLessThan(abs(note.cents), 1.0) // Within 1 cent
    }

    func testClassifyLowE() {
        let note = NoteClassifier.classify(frequency: 82.41, referencePitch: 440.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertEqual(note.octave, 2)
        XCTAssertLessThan(abs(note.cents), 5.0) // ~0.8 cents off
    }

    func testClassifyHighE() {
        let note = NoteClassifier.classify(frequency: 329.63, referencePitch: 440.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertEqual(note.octave, 4)
        XCTAssertLessThan(abs(note.cents), 5.0)
    }

    func testClassifyA432() {
        let note = NoteClassifier.classify(frequency: 432.0, referencePitch: 432.0)
        XCTAssertEqual(note.name, "A")
        XCTAssertEqual(note.octave, 4)
        XCTAssertLessThan(abs(note.cents), 1.0)
    }

    func testCentsDeviationPositive() {
        // E2 at 83.0 Hz should be sharp by ~12.3 cents
        let note = NoteClassifier.classify(frequency: 83.0, referencePitch: 440.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertGreaterThan(note.cents, 10.0)
        XCTAssertLessThan(note.cents, 15.0)
    }

    func testCentsDeviationNegative() {
        // E2 at 82.0 Hz should be flat by ~-8.6 cents
        let note = NoteClassifier.classify(frequency: 82.0, referencePitch: 440.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertLessThan(note.cents, -5.0)
        XCTAssertGreaterThan(note.cents, -12.0)
    }

    func testReferencePitch432() {
        // With A4 = 432 Hz, calculate the correct E2 frequency
        // E2 is 4 octaves + 7 semitones below A4
        // Using frequencyFor to get exact value
        let e2At432 = NoteClassifier.frequencyFor(note: "E", octave: 2, referencePitch: 432.0)!
        let note = NoteClassifier.classify(frequency: e2At432, referencePitch: 432.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertEqual(note.octave, 2)
        XCTAssertLessThan(abs(note.cents), 1.0)
    }

    func testFrequencyForNote() {
        let a4 = NoteClassifier.frequencyFor(note: "A", octave: 4, referencePitch: 440.0)
        XCTAssertEqual(a4!, 440.0, accuracy: 0.01)

        let e2 = NoteClassifier.frequencyFor(note: "E", octave: 2, referencePitch: 440.0)
        XCTAssertEqual(e2!, 82.41, accuracy: 0.01)
    }

    func testAllNotes() {
        // Verify all note names are recognized
        for name in NoteClassifier.noteNames {
            let freq = NoteClassifier.frequencyFor(note: name, octave: 4, referencePitch: 440.0)
            XCTAssertNotNil(freq)
        }
    }

    func testInvalidNoteReturnsNil() {
        XCTAssertNil(NoteClassifier.frequencyFor(note: "H", octave: 4, referencePitch: 440.0))
    }

    func testZeroFrequency() {
        let note = NoteClassifier.classify(frequency: 0, referencePitch: 440.0)
        XCTAssertEqual(note.name, "-")
    }

    // MARK: - Reference Pitch 443 Hz Tests

    func testReferencePitch443() {
        // A4 = 443 Hz (orchestral pitch)
        let note = NoteClassifier.classify(frequency: 443.0, referencePitch: 443.0)
        XCTAssertEqual(note.name, "A")
        XCTAssertEqual(note.octave, 4)
        XCTAssertLessThan(abs(note.cents), 1.0)
    }

    func testE2At443Hz() {
        // With A4 = 443 Hz, E2 = 83.03 Hz
        // Use NoteClassifier's frequencyFor to calculate expected frequency
        let expectedE2 = NoteClassifier.frequencyFor(note: "E", octave: 2, referencePitch: 443.0)!
        let note = NoteClassifier.classify(frequency: expectedE2, referencePitch: 443.0)
        XCTAssertEqual(note.name, "E")
        XCTAssertEqual(note.octave, 2)
        XCTAssertLessThan(abs(note.cents), 1.0)
    }
}
