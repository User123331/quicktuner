import Foundation

let presetTunings: [Tuning] = [
    // MARK: - 6-String Guitar (19 tunings)

    // Standard Tunings
    Tuning(
        name: "E Standard",
        instrument: .guitar6,
        category: .standard,
        notes: [
            TuningNote(name: "E", octave: 4),  // String 1 (high)
            TuningNote(name: "B", octave: 3),  // String 2
            TuningNote(name: "G", octave: 3),  // String 3
            TuningNote(name: "D", octave: 3),  // String 4
            TuningNote(name: "A", octave: 2),  // String 5
            TuningNote(name: "E", octave: 2)   // String 6 (low)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Eb Standard",
        instrument: .guitar6,
        category: .standard,
        notes: [
            TuningNote(name: "Eb", octave: 4),
            TuningNote(name: "Bb", octave: 3),
            TuningNote(name: "Gb", octave: 3),
            TuningNote(name: "Db", octave: 3),
            TuningNote(name: "Ab", octave: 2),
            TuningNote(name: "Eb", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "D Standard",
        instrument: .guitar6,
        category: .standard,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "F", octave: 3),
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),

    // Drop Tunings
    Tuning(
        name: "Drop D",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop C#",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "Eb", octave: 4),
            TuningNote(name: "Bb", octave: 3),
            TuningNote(name: "F#", octave: 3),
            TuningNote(name: "C#", octave: 3),
            TuningNote(name: "G#", octave: 2),
            TuningNote(name: "C#", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop C",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "F", octave: 3),
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "C", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop B",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "C#", octave: 4),
            TuningNote(name: "G#", octave: 3),
            TuningNote(name: "E", octave: 3),
            TuningNote(name: "B", octave: 2),
            TuningNote(name: "F#", octave: 2),
            TuningNote(name: "B", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop A#",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "C", octave: 4),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "Eb", octave: 3),
            TuningNote(name: "Bb", octave: 2),
            TuningNote(name: "F", octave: 2),
            TuningNote(name: "Bb", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop A",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "F#", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "A", octave: 1)
        ],
        isPreset: true
    ),

    // Double Drop Tunings
    Tuning(
        name: "Double Drop D",
        instrument: .guitar6,
        category: .drop,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),

    // Open Tunings
    Tuning(
        name: "Open G",
        instrument: .guitar6,
        category: .open,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Open D",
        instrument: .guitar6,
        category: .open,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "F#", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Open E",
        instrument: .guitar6,
        category: .open,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G#", octave: 3),
            TuningNote(name: "E", octave: 3),
            TuningNote(name: "B", octave: 2),
            TuningNote(name: "E", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Open A",
        instrument: .guitar6,
        category: .open,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "C#", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "E", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Open C",
        instrument: .guitar6,
        category: .open,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "C", octave: 4),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "C", octave: 2)
        ],
        isPreset: true
    ),

    // Modal/Alternative Tunings
    Tuning(
        name: "DADGAD",
        instrument: .guitar6,
        category: .modal,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "D Modal (Dsus2)",
        instrument: .guitar6,
        category: .modal,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Nick Drake Tuning (C6)",
        instrument: .guitar6,
        category: .modal,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "C", octave: 4),
            TuningNote(name: "C", octave: 4),
            TuningNote(name: "F", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "C", octave: 2)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Orkney Tuning",
        instrument: .guitar6,
        category: .modal,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "C", octave: 4),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "C", octave: 2)
        ],
        isPreset: true
    ),

    // MARK: - 7-String Guitar (7 tunings)

    Tuning(
        name: "B Standard",
        instrument: .guitar7,
        category: .standard,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "B", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "A Standard",
        instrument: .guitar7,
        category: .standard,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "A", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop A (7-String)",
        instrument: .guitar7,
        category: .drop,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "A", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop G#",
        instrument: .guitar7,
        category: .drop,
        notes: [
            TuningNote(name: "Eb", octave: 4),
            TuningNote(name: "Bb", octave: 3),
            TuningNote(name: "Gb", octave: 3),
            TuningNote(name: "Db", octave: 3),
            TuningNote(name: "Ab", octave: 2),
            TuningNote(name: "Eb", octave: 2),
            TuningNote(name: "Ab", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop G",
        instrument: .guitar7,
        category: .drop,
        notes: [
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "A", octave: 3),
            TuningNote(name: "F", octave: 3),
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "G", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Russian Open G Minor",
        instrument: .guitar7,
        category: .open,
        notes: [
            TuningNote(name: "G", octave: 4),
            TuningNote(name: "D", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2)
        ],
        isPreset: true
    ),

    // MARK: - 8-String Guitar (3 tunings)

    Tuning(
        name: "F# Standard",
        instrument: .guitar8,
        category: .standard,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "B", octave: 1),
            TuningNote(name: "F#", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "E Standard 8-String",
        instrument: .guitar8,
        category: .standard,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "B", octave: 1),
            TuningNote(name: "E", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop E",
        instrument: .guitar8,
        category: .drop,
        notes: [
            TuningNote(name: "E", octave: 4),
            TuningNote(name: "B", octave: 3),
            TuningNote(name: "G", octave: 3),
            TuningNote(name: "D", octave: 3),
            TuningNote(name: "A", octave: 2),
            TuningNote(name: "E", octave: 2),
            TuningNote(name: "B", octave: 1),
            TuningNote(name: "E", octave: 1)
        ],
        isPreset: true
    ),

    // MARK: - 4-String Bass (4 tunings)

    Tuning(
        name: "E Standard (Bass)",
        instrument: .bass4,
        category: .standard,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop D (Bass)",
        instrument: .bass4,
        category: .drop,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "D", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop C (Bass)",
        instrument: .bass4,
        category: .drop,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "C", octave: 1)
        ],
        isPreset: true
    ),
    Tuning(
        name: "D Standard (Bass)",
        instrument: .bass4,
        category: .standard,
        notes: [
            TuningNote(name: "F", octave: 2),
            TuningNote(name: "C", octave: 2),
            TuningNote(name: "G", octave: 1),
            TuningNote(name: "D", octave: 1)
        ],
        isPreset: true
    ),

    // MARK: - 5-String Bass (3 tunings)

    Tuning(
        name: "B Standard (Bass)",
        instrument: .bass5,
        category: .standard,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1),
            TuningNote(name: "B", octave: 0)
        ],
        isPreset: true
    ),
    Tuning(
        name: "Drop A (Bass)",
        instrument: .bass5,
        category: .drop,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1),
            TuningNote(name: "A", octave: 0)
        ],
        isPreset: true
    ),
    Tuning(
        name: "High C Extension",
        instrument: .bass5,
        category: .alternative,
        notes: [
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1)
        ],
        isPreset: true
    ),

    // MARK: - 6-String Bass (2 tunings)

    Tuning(
        name: "Standard 6-String Bass",
        instrument: .bass6,
        category: .standard,
        notes: [
            TuningNote(name: "C", octave: 3),
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1),
            TuningNote(name: "B", octave: 0)
        ],
        isPreset: true
    ),
    Tuning(
        name: "F# Standard 6-String",
        instrument: .bass6,
        category: .standard,
        notes: [
            TuningNote(name: "G", octave: 2),
            TuningNote(name: "D", octave: 2),
            TuningNote(name: "A", octave: 1),
            TuningNote(name: "E", octave: 1),
            TuningNote(name: "B", octave: 0),
            TuningNote(name: "F#", octave: 0)
        ],
        isPreset: true
    )
]
