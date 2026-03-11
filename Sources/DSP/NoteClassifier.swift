import Foundation
import Accelerate

struct NoteClassifier {
    static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    /// Classify a frequency into a note with cents deviation
    /// - Parameters:
    ///   - frequency: Detected frequency in Hz
    ///   - referencePitch: Reference pitch for A4 (default 440.0 Hz)
    /// - Returns: Note with name, octave, and cents deviation
    static func classify(frequency: Double, referencePitch: Double = 440.0) -> Note {
        guard frequency > 0 else {
            return Note(name: "-", octave: 0, cents: 0, frequency: 0)
        }

        // Calculate MIDI note number
        // Formula: 69 + 12 * log2(frequency / referencePitch)
        let midiNote = 69 + 12 * log2(frequency / referencePitch)
        let roundedMidi = round(midiNote)

        // Extract note index and octave
        var noteIndex = Int(roundedMidi) % 12
        if noteIndex < 0 { noteIndex += 12 }

        let octave = (Int(roundedMidi) / 12) - 1

        // Calculate cents deviation from equal temperament
        let cents = (midiNote - roundedMidi) * 100

        return Note(
            name: noteNames[noteIndex],
            octave: octave,
            cents: cents,
            frequency: frequency
        )
    }

    /// Calculate frequency for a given MIDI note number
    static func frequencyFor(midiNote: Double, referencePitch: Double = 440.0) -> Double {
        return referencePitch * pow(2, (midiNote - 69) / 12)
    }

    /// Calculate frequency for a note name and octave
    static func frequencyFor(note: String, octave: Int, referencePitch: Double = 440.0) -> Double? {
        guard let noteIndex = noteNames.firstIndex(of: note) else { return nil }
        let midiNote = Double((octave + 1) * 12 + noteIndex)
        return frequencyFor(midiNote: midiNote, referencePitch: referencePitch)
    }
}
