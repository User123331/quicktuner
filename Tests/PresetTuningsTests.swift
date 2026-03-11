import Foundation
import Testing
@testable import QuickTuner

@Suite("PresetTunings Tests")
struct PresetTuningsTests {

    @Test("Preset tunings count is 37")
    func presetTuningsCount() {
        #expect(presetTunings.count == 37)
    }

    @Test("All presets are marked as isPreset")
    func allPresetsMarked() {
        let allMarked = presetTunings.allSatisfy { $0.isPreset }
        #expect(allMarked == true)
    }

    @Test("No presets are custom tunings")
    func noPresetsAreCustom() {
        let noneCustom = presetTunings.allSatisfy { !$0.isCustom }
        #expect(noneCustom == true)
    }

    @Test("6-string guitar has 19 tunings")
    func guitar6StringCount() {
        let guitar6Tunings = presetTunings.filter { $0.instrument == .guitar6 }
        #expect(guitar6Tunings.count == 19)
    }

    @Test("7-string guitar has 6 tunings")
    func guitar7StringCount() {
        let guitar7Tunings = presetTunings.filter { $0.instrument == .guitar7 }
        #expect(guitar7Tunings.count == 6)
    }

    @Test("8-string guitar has 3 tunings")
    func guitar8StringCount() {
        let guitar8Tunings = presetTunings.filter { $0.instrument == .guitar8 }
        #expect(guitar8Tunings.count == 3)
    }

    @Test("4-string bass has 4 tunings")
    func bass4StringCount() {
        let bass4Tunings = presetTunings.filter { $0.instrument == .bass4 }
        #expect(bass4Tunings.count == 4)
    }

    @Test("5-string bass has 3 tunings")
    func bass5StringCount() {
        let bass5Tunings = presetTunings.filter { $0.instrument == .bass5 }
        #expect(bass5Tunings.count == 3)
    }

    @Test("6-string bass has 2 tunings")
    func bass6StringCount() {
        let bass6Tunings = presetTunings.filter { $0.instrument == .bass6 }
        #expect(bass6Tunings.count == 2)
    }

    @Test("E Standard guitar has correct notes")
    func eStandardGuitarNotes() {
        let eStandard = presetTunings.first { $0.name == "E Standard" && $0.instrument == .guitar6 }
        #expect(eStandard != nil)

        let notes = eStandard!.notes
        #expect(notes.count == 6)
        #expect(notes[0].name == "E" && notes[0].octave == 4)  // String 1 (high)
        #expect(notes[1].name == "B" && notes[1].octave == 3)
        #expect(notes[2].name == "G" && notes[2].octave == 3)
        #expect(notes[3].name == "D" && notes[3].octave == 3)
        #expect(notes[4].name == "A" && notes[4].octave == 2)
        #expect(notes[5].name == "E" && notes[5].octave == 2)  // String 6 (low)
    }

    @Test("Drop D guitar has correct notes")
    func dropDGuitarNotes() {
        let dropD = presetTunings.first { $0.name == "Drop D" && $0.instrument == .guitar6 }
        #expect(dropD != nil)

        let notes = dropD!.notes
        #expect(notes.count == 6)
        #expect(notes[5].name == "D" && notes[5].octave == 2)  // Low string dropped
    }

    @Test("B Standard 7-string has correct notes")
    func bStandard7StringNotes() {
        let bStandard = presetTunings.first { $0.name == "B Standard" && $0.instrument == .guitar7 }
        #expect(bStandard != nil)

        let notes = bStandard!.notes
        #expect(notes.count == 7)
        #expect(notes[6].name == "B" && notes[6].octave == 1)  // 7th string low B
    }

    @Test("F# Standard 8-string has correct notes")
    func fSharpStandard8StringNotes() {
        let fSharpStandard = presetTunings.first { $0.name == "F# Standard" && $0.instrument == .guitar8 }
        #expect(fSharpStandard != nil)

        let notes = fSharpStandard!.notes
        #expect(notes.count == 8)
        #expect(notes[7].name == "F#" && notes[7].octave == 1)  // 8th string low F#
    }

    @Test("E Standard bass has correct notes")
    func eStandardBassNotes() {
        let eStandardBass = presetTunings.first { $0.name == "E Standard (Bass)" }
        #expect(eStandardBass != nil)

        let notes = eStandardBass!.notes
        #expect(notes.count == 4)
        #expect(notes[0].name == "G" && notes[0].octave == 2)   // String 1 (high)
        #expect(notes[1].name == "D" && notes[1].octave == 2)
        #expect(notes[2].name == "A" && notes[2].octave == 1)
        #expect(notes[3].name == "E" && notes[3].octave == 1)   // String 4 (low)
    }

    @Test("B Standard 5-string bass has correct notes")
    func bStandard5StringBassNotes() {
        let bStandardBass = presetTunings.first { $0.name == "B Standard (Bass)" }
        #expect(bStandardBass != nil)

        let notes = bStandardBass!.notes
        #expect(notes.count == 5)
        #expect(notes[4].name == "B" && notes[4].octave == 0)  // Low B octave 0
    }

    @Test("All tunings have correct string count for their instrument")
    func tuningStringCountsMatchInstrument() {
        for tuning in presetTunings {
            #expect(tuning.notes.count == tuning.instrument.stringCount,
                   "Tuning '\(tuning.name)' has \(tuning.notes.count) notes but instrument expects \(tuning.instrument.stringCount)")
        }
    }

    @Test("Open G tuning has correct notes")
    func openGTuningNotes() {
        let openG = presetTunings.first { $0.name == "Open G" }
        #expect(openG != nil)

        let notes = openG!.notes
        #expect(notes[0].name == "D" && notes[0].octave == 4)
        #expect(notes[1].name == "B" && notes[1].octave == 3)
        #expect(notes[2].name == "G" && notes[2].octave == 3)
        #expect(notes[3].name == "D" && notes[3].octave == 3)
        #expect(notes[4].name == "G" && notes[4].octave == 2)
        #expect(notes[5].name == "D" && notes[5].octave == 2)
    }

    @Test("DADGAD tuning has correct notes")
    func dadgadTuningNotes() {
        let dadgad = presetTunings.first { $0.name == "DADGAD" }
        #expect(dadgad != nil)

        let notes = dadgad!.notes
        #expect(notes[0].name == "D" && notes[0].octave == 4)
        #expect(notes[1].name == "A" && notes[1].octave == 3)
        #expect(notes[2].name == "G" && notes[2].octave == 3)
        #expect(notes[3].name == "D" && notes[3].octave == 3)
        #expect(notes[4].name == "A" && notes[4].octave == 2)
        #expect(notes[5].name == "D" && notes[5].octave == 2)
    }
}
