import Foundation
import Testing
@testable import QuickTuner

@Suite("TuningLibrary Tests")
struct TuningLibraryTests {

    @Test("TuningLibrary initializes with correct default state")
    func initialState() async {
        let library = await TuningLibrary()

        // Should default to guitar6
        let selectedInstrument = await library.selectedInstrument
        #expect(selectedInstrument == .guitar6)

        // Should have tunings available
        let availableTunings = await library.availableTunings
        #expect(availableTunings.count > 0)

        // Should auto-select first tuning
        let selectedTuning = await library.selectedTuning
        #expect(selectedTuning != nil)
    }

    @Test("TuningLibrary returns correct tunings for instrument")
    func tuningsForInstrument() async {
        let library = await TuningLibrary()

        let guitar6Tunings = await library.tunings(for: .guitar6)
        #expect(guitar6Tunings.count == 19)

        let guitar7Tunings = await library.tunings(for: .guitar7)
        #expect(guitar7Tunings.count == 6)

        let bass4Tunings = await library.tunings(for: .bass4)
        #expect(bass4Tunings.count == 4)
    }

    @Test("Changing selectedInstrument updates availableTunings")
    func instrumentChangeUpdatesTunings() async {
        let library = await TuningLibrary()

        // Start with guitar6
        let initialTunings = await library.availableTunings
        #expect(initialTunings.count == 19)

        // Change to bass4
        await library.selectInstrument(.bass4)

        let newTunings = await library.availableTunings
        #expect(newTunings.count == 4)
    }

    @Test("Changing instrument auto-selects first tuning")
    func instrumentChangeAutoSelectsTuning() async {
        let library = await TuningLibrary()

        await library.selectInstrument(.guitar7)

        let selectedTuning = await library.selectedTuning
        #expect(selectedTuning != nil)
        #expect(selectedTuning?.instrument == .guitar7)
    }

    @Test("selectTuning updates selectedTuning")
    func selectTuning() async {
        let library = await TuningLibrary()

        let dropDTuning = presetTunings.first { $0.name == "Drop D" && $0.instrument == .guitar6 }
        #expect(dropDTuning != nil)

        await library.selectTuning(dropDTuning!)

        let selectedTuning = await library.selectedTuning
        #expect(selectedTuning?.name == "Drop D")
    }

    @Test("selectTuning by id works correctly")
    func selectTuningById() async {
        let library = await TuningLibrary()

        let eStandard = presetTunings.first { $0.name == "E Standard" && $0.instrument == .guitar6 }
        #expect(eStandard != nil)

        await library.selectTuning(id: eStandard!.id)

        let selectedTuning = await library.selectedTuning
        #expect(selectedTuning?.id == eStandard!.id)
    }

    @Test("Adding custom tuning increases available tunings")
    func addCustomTuning() async {
        let library = await TuningLibrary()

        let initialCount = await library.availableTunings.count

        let customNotes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ]

        let customTuning = Tuning(
            name: "My Custom Tuning",
            instrument: .guitar6,
            category: .custom,
            notes: customNotes,
            isCustom: true,
            isPreset: false
        )

        await library.addCustomTuning(customTuning)

        let newCount = await library.availableTunings.count
        #expect(newCount == initialCount + 1)
        #expect(await library.availableTunings.contains { $0.name == "My Custom Tuning" })
    }

    @Test("Adding non-custom tuning is rejected")
    func addNonCustomTuningRejected() async {
        let library = await TuningLibrary()

        let initialCount = await library.availableTunings.count

        let presetNotes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2)
        ]

        // Try to add a tuning that's NOT marked as custom
        let nonCustomTuning = Tuning(
            name: "Fake Preset",
            instrument: .guitar6,
            category: .standard,
            notes: presetNotes,
            isCustom: false,  // Not custom!
            isPreset: false
        )

        await library.addCustomTuning(nonCustomTuning)

        let newCount = await library.availableTunings.count
        #expect(newCount == initialCount)  // Should not have increased
    }

    @Test("Removing custom tuning decreases available tunings")
    func removeCustomTuning() async {
        let library = await TuningLibrary()

        let customNotes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ]

        let customTuning = Tuning(
            name: "Temp Tuning",
            instrument: .guitar6,
            category: .custom,
            notes: customNotes,
            isCustom: true,
            isPreset: false
        )

        await library.addCustomTuning(customTuning)
        let addedCount = await library.availableTunings.count
        #expect(addedCount > 19)  // Should be more than just presets

        await library.removeCustomTuning(id: customTuning.id)
        let removedCount = await library.availableTunings.count
        #expect(removedCount == 19)  // Back to just presets
    }

    @Test("Custom tunings are filtered by instrument")
    func customTuningsFilteredByInstrument() async {
        let library = await TuningLibrary()

        // Add custom tuning for guitar6
        let customNotes = [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ]

        let customTuning = Tuning(
            name: "Guitar6 Custom",
            instrument: .guitar6,
            category: .custom,
            notes: customNotes,
            isCustom: true,
            isPreset: false
        )

        await library.addCustomTuning(customTuning)

        // Should be in guitar6 tunings
        let guitar6Tunings = await library.tunings(for: .guitar6)
        #expect(guitar6Tunings.contains { $0.name == "Guitar6 Custom" })

        // Should NOT be in guitar7 tunings
        let guitar7Tunings = await library.tunings(for: .guitar7)
        #expect(!guitar7Tunings.contains { $0.name == "Guitar6 Custom" })
    }

    @Test("Selecting unavailable tuning deselects it")
    func selectingUnavailableTuningDeselects() async {
        let library = await TuningLibrary()

        // Select a guitar6 tuning
        await library.selectInstrument(.guitar6)
        let guitar6Tuning = await library.selectedTuning
        #expect(guitar6Tuning != nil)

        // Switch to bass4
        await library.selectInstrument(.bass4)

        // Selected tuning should now be a bass tuning
        let bassTuning = await library.selectedTuning
        #expect(bassTuning != nil)
        #expect(bassTuning?.instrument == .bass4)
    }
}

// Extension to allow testing instrument selection
extension TuningLibrary {
    func selectInstrument(_ instrument: InstrumentType) {
        selectedInstrument = instrument
    }
}
