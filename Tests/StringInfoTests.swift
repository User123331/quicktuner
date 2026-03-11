import Testing
@testable import QuickTuner

@Suite("StringInfo Tests")
struct StringInfoTests {

    @Test("StringInfo has required properties")
    func stringInfoProperties() {
        let note = Note(name: "E", octave: 2, cents: 0, frequency: 82.41)
        let string = StringInfo(id: 1, note: note, isTuned: false)

        #expect(string.id == 1)
        #expect(string.note.name == "E")
        #expect(string.note.octave == 2)
        #expect(string.isTuned == false)
    }

    @Test("StringInfo conforms to Identifiable")
    func identifiableConformance() {
        let note = Note(name: "A", octave: 2, cents: 0, frequency: 110.0)
        let string = StringInfo(id: 2, note: note, isTuned: true)

        // Identifiable requires id property
        let _: any Identifiable = string
        #expect(string.id == 2)
    }

    @Test("StringInfo conforms to Hashable")
    func hashableConformance() {
        let note1 = Note(name: "E", octave: 2, cents: 0, frequency: 82.41)
        let note2 = Note(name: "A", octave: 2, cents: 0, frequency: 110.0)

        let string1 = StringInfo(id: 1, note: note1, isTuned: false)
        let string1Copy = StringInfo(id: 1, note: note1, isTuned: false)
        let string2 = StringInfo(id: 2, note: note2, isTuned: false)

        // Hashable requires equatable
        #expect(string1 == string1Copy)
        #expect(string1 != string2)
    }

    @Test("Standard guitar strings configuration")
    func standardGuitarStrings() {
        let strings = StringInfo.standardGuitar

        #expect(strings.count == 6)

        // String 1: E2 (low E)
        #expect(strings[0].id == 1)
        #expect(strings[0].note.name == "E")
        #expect(strings[0].note.octave == 2)
        #expect(strings[0].isTuned == false)

        // String 2: A2
        #expect(strings[1].id == 2)
        #expect(strings[1].note.name == "A")
        #expect(strings[1].note.octave == 2)

        // String 3: D3
        #expect(strings[2].id == 3)
        #expect(strings[2].note.name == "D")
        #expect(strings[2].note.octave == 3)

        // String 4: G3
        #expect(strings[3].id == 4)
        #expect(strings[3].note.name == "G")
        #expect(strings[3].note.octave == 3)

        // String 5: B3
        #expect(strings[4].id == 5)
        #expect(strings[4].note.name == "B")
        #expect(strings[4].note.octave == 3)

        // String 6: E4 (high E)
        #expect(strings[5].id == 6)
        #expect(strings[5].note.name == "E")
        #expect(strings[5].note.octave == 4)
    }

    @Test("Standard bass strings configuration")
    func standardBassStrings() {
        let strings = StringInfo.standardBass

        #expect(strings.count == 4)

        // String 1: B1 (low B)
        #expect(strings[0].id == 1)
        #expect(strings[0].note.name == "B")
        #expect(strings[0].note.octave == 1)

        // String 2: E2
        #expect(strings[1].id == 2)
        #expect(strings[1].note.name == "E")
        #expect(strings[1].note.octave == 2)

        // String 3: A2
        #expect(strings[2].id == 3)
        #expect(strings[2].note.name == "A")
        #expect(strings[2].note.octave == 2)

        // String 4: D3
        #expect(strings[3].id == 4)
        #expect(strings[3].note.name == "D")
        #expect(strings[3].note.octave == 3)
    }

    @Test("isTuned property is mutable")
    func tunedPropertyMutability() {
        var string = StringInfo(id: 1, note: Note(name: "E", octave: 2, cents: 0, frequency: 82.41), isTuned: false)

        #expect(string.isTuned == false)

        string.isTuned = true

        #expect(string.isTuned == true)
    }
}
