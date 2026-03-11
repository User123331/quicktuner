import Foundation

/// Represents a guitar or bass string with its target note and tuning state
struct StringInfo: Identifiable, Hashable, Sendable {
    let id: Int              // 1-6 for guitar, 1-4 for bass
    let note: Note           // Target note
    var isTuned: Bool        // Checkmark state

    init(id: Int, note: Note, isTuned: Bool = false) {
        self.id = id
        self.note = note
        self.isTuned = isTuned
    }
}

// MARK: - Standard Tunings

extension StringInfo {
    /// Standard guitar tuning: E2, A2, D3, G3, B3, E4
    /// String 1 is the low E (thickest), String 6 is the high E (thinnest)
    static let standardGuitar: [StringInfo] = [
        StringInfo(id: 1, note: Note(name: "E", octave: 2, cents: 0, frequency: 82.41)),
        StringInfo(id: 2, note: Note(name: "A", octave: 2, cents: 0, frequency: 110.00)),
        StringInfo(id: 3, note: Note(name: "D", octave: 3, cents: 0, frequency: 146.83)),
        StringInfo(id: 4, note: Note(name: "G", octave: 3, cents: 0, frequency: 196.00)),
        StringInfo(id: 5, note: Note(name: "B", octave: 3, cents: 0, frequency: 246.94)),
        StringInfo(id: 6, note: Note(name: "E", octave: 4, cents: 0, frequency: 329.63))
    ]

    /// Standard bass guitar tuning: B1, E2, A2, D3 (for 4-string bass)
    /// String 1 is the low B (thickest), String 4 is the high D (thinnest)
    static let standardBass: [StringInfo] = [
        StringInfo(id: 1, note: Note(name: "B", octave: 1, cents: 0, frequency: 30.87)),
        StringInfo(id: 2, note: Note(name: "E", octave: 2, cents: 0, frequency: 82.41)),
        StringInfo(id: 3, note: Note(name: "A", octave: 2, cents: 0, frequency: 110.00)),
        StringInfo(id: 4, note: Note(name: "D", octave: 3, cents: 0, frequency: 146.83))
    ]
}
