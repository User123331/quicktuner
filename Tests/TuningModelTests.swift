import Foundation
import Testing
@testable import QuickTuner

@Suite("Tuning Model Tests")
struct TuningModelTests {

    @Test("TuningNote encodes and decodes correctly")
    func tuningNoteCodable() throws {
        let note = TuningNote(name: "E", octave: 2)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(note)
        let decoded = try decoder.decode(TuningNote.self, from: data)

        #expect(decoded.name == "E")
        #expect(decoded.octave == 2)
    }

    @Test("TuningNote hashable conformance")
    func tuningNoteHashable() {
        let note1 = TuningNote(name: "E", octave: 2)
        let note1Copy = TuningNote(name: "E", octave: 2)
        let note2 = TuningNote(name: "A", octave: 2)

        #expect(note1 == note1Copy)
        #expect(note1 != note2)
    }

    @Test("InstrumentType display names are correct")
    func instrumentTypeDisplayNames() {
        #expect(InstrumentType.guitar6.displayName == "Guitar (6-String)")
        #expect(InstrumentType.guitar7.displayName == "Guitar (7-String)")
        #expect(InstrumentType.guitar8.displayName == "Guitar (8-String)")
        #expect(InstrumentType.bass4.displayName == "Bass (4-String)")
        #expect(InstrumentType.bass5.displayName == "Bass (5-String)")
        #expect(InstrumentType.bass6.displayName == "Bass (6-String)")
    }

    @Test("InstrumentType string counts are correct")
    func instrumentTypeStringCounts() {
        #expect(InstrumentType.guitar6.stringCount == 6)
        #expect(InstrumentType.guitar7.stringCount == 7)
        #expect(InstrumentType.guitar8.stringCount == 8)
        #expect(InstrumentType.bass4.stringCount == 4)
        #expect(InstrumentType.bass5.stringCount == 5)
        #expect(InstrumentType.bass6.stringCount == 6)
    }

    @Test("InstrumentType conforms to CaseIterable")
    func instrumentTypeCaseIterable() {
        let allCases = InstrumentType.allCases
        #expect(allCases.count == 6)
        #expect(allCases.contains(.guitar6))
        #expect(allCases.contains(.guitar7))
        #expect(allCases.contains(.guitar8))
        #expect(allCases.contains(.bass4))
        #expect(allCases.contains(.bass5))
        #expect(allCases.contains(.bass6))
    }

    @Test("TuningCategory display names are correct")
    func tuningCategoryDisplayNames() {
        #expect(TuningCategory.standard.displayName == "Standard")
        #expect(TuningCategory.drop.displayName == "Drop")
        #expect(TuningCategory.open.displayName == "Open")
        #expect(TuningCategory.modal.displayName == "Modal")
        #expect(TuningCategory.alternative.displayName == "Alternative")
        #expect(TuningCategory.custom.displayName == "Custom")
    }

    @Test("Tuning encodes and decodes correctly")
    func tuningCodable() throws {
        let notes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2)
        ]

        let tuning = Tuning(
            name: "E Standard",
            instrument: .guitar6,
            category: .standard,
            notes: notes,
            isPreset: true
        )

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(tuning)
        let decoded = try decoder.decode(Tuning.self, from: data)

        #expect(decoded.name == "E Standard")
        #expect(decoded.instrument == .guitar6)
        #expect(decoded.category == .standard)
        #expect(decoded.notes.count == 6)
        #expect(decoded.isPreset == true)
        #expect(decoded.isCustom == false)
    }

    @Test("Tuning noteNames property formats correctly")
    func tuningNoteNamesProperty() {
        let notes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3)
        ]

        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .standard,
            notes: notes
        )

        #expect(tuning.noteNames == "E4-B3-G3")
    }

    @Test("Tuning conforms to Identifiable")
    func tuningIdentifiable() {
        let notes = [TuningNote(name: "E", octave: 2)]
        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .standard,
            notes: notes
        )

        let _: any Identifiable = tuning
        #expect(tuning.id != UUID())
    }

    @Test("Tuning conforms to Hashable")
    func tuningHashable() {
        let notes = [TuningNote(name: "E", octave: 2)]
        let tuning1 = Tuning(
            id: UUID(),
            name: "Test",
            instrument: .guitar6,
            category: .standard,
            notes: notes
        )
        let tuning1Copy = Tuning(
            id: tuning1.id,
            name: "Test",
            instrument: .guitar6,
            category: .standard,
            notes: notes
        )
        let tuning2 = Tuning(
            name: "Other",
            instrument: .guitar6,
            category: .standard,
            notes: notes
        )

        #expect(tuning1 == tuning1Copy)
        #expect(tuning1 != tuning2)
    }
}
