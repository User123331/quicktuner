import SwiftUI

struct CustomTuningCreator: View {
    let instrument: InstrumentType
    let onSave: (Tuning) -> Void
    let onCancel: () -> Void

    @State private var tuningName: String = ""
    @State private var notes: [TuningNote]

    private let availableNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let availableOctaves = [0, 1, 2, 3, 4, 5]

    init(
        instrument: InstrumentType,
        onSave: @escaping (Tuning) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.instrument = instrument
        self.onSave = onSave
        self.onCancel = onCancel

        // Initialize with standard tuning for this instrument
        let standardNotes: [TuningNote]
        switch instrument {
        case .guitar6:
            standardNotes = [
                TuningNote(name: "E", octave: 4),
                TuningNote(name: "B", octave: 3),
                TuningNote(name: "G", octave: 3),
                TuningNote(name: "D", octave: 3),
                TuningNote(name: "A", octave: 2),
                TuningNote(name: "E", octave: 2)
            ]
        case .guitar7:
            standardNotes = [
                TuningNote(name: "E", octave: 4),
                TuningNote(name: "B", octave: 3),
                TuningNote(name: "G", octave: 3),
                TuningNote(name: "D", octave: 3),
                TuningNote(name: "A", octave: 2),
                TuningNote(name: "E", octave: 2),
                TuningNote(name: "B", octave: 1)
            ]
        case .guitar8:
            standardNotes = [
                TuningNote(name: "E", octave: 4),
                TuningNote(name: "B", octave: 3),
                TuningNote(name: "G", octave: 3),
                TuningNote(name: "D", octave: 3),
                TuningNote(name: "A", octave: 2),
                TuningNote(name: "E", octave: 2),
                TuningNote(name: "B", octave: 1),
                TuningNote(name: "F#", octave: 1)
            ]
        case .bass4:
            standardNotes = [
                TuningNote(name: "G", octave: 2),
                TuningNote(name: "D", octave: 2),
                TuningNote(name: "A", octave: 1),
                TuningNote(name: "E", octave: 1)
            ]
        case .bass5:
            standardNotes = [
                TuningNote(name: "G", octave: 2),
                TuningNote(name: "D", octave: 2),
                TuningNote(name: "A", octave: 1),
                TuningNote(name: "E", octave: 1),
                TuningNote(name: "B", octave: 0)
            ]
        case .bass6:
            standardNotes = [
                TuningNote(name: "C", octave: 3),
                TuningNote(name: "G", octave: 2),
                TuningNote(name: "D", octave: 2),
                TuningNote(name: "A", octave: 1),
                TuningNote(name: "E", octave: 1),
                TuningNote(name: "B", octave: 0)
            ]
        }
        _notes = State(initialValue: standardNotes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tuning Information") {
                    TextField("Tuning Name", text: $tuningName)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Text("Instrument:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(instrument.displayName)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("Strings:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(instrument.stringCount)")
                            .fontWeight(.medium)
                    }
                }

                Section("String Notes (High to Low)") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set the note for each string, from highest pitch (string 1) to lowest pitch (string \(instrument.stringCount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(0..<instrument.stringCount, id: \.self) { index in
                            StringNotePicker(
                                stringNumber: index + 1,
                                note: noteBinding(for: index)
                            )
                        }
                    }
                }

                Section("Preview") {
                    HStack {
                        Text("Notes:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(notePreview)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Create Custom Tuning")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(tuningName.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }

    private func noteBinding(for index: Int) -> Binding<TuningNote> {
        Binding(
            get: {
                guard index < notes.count else {
                    return TuningNote(name: "E", octave: 2)
                }
                return notes[index]
            },
            set: { newValue in
                if index < notes.count {
                    notes[index] = newValue
                }
            }
        )
    }

    private var notePreview: String {
        notes.map { "\($0.name)\($0.octave)" }.joined(separator: "-")
    }

    private func save() {
        let tuning = Tuning(
            name: tuningName,
            instrument: instrument,
            category: .custom,
            notes: notes,
            isCustom: true,
            isPreset: false
        )
        onSave(tuning)
    }
}

struct StringNotePicker: View {
    let stringNumber: Int
    @Binding var note: TuningNote

    private let availableNotes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    private let availableOctaves = [0, 1, 2, 3, 4, 5]

    var body: some View {
        HStack {
            Text("String \(stringNumber)")
                .font(.system(.body, design: .monospaced))
                .frame(width: 70, alignment: .leading)

            Spacer()

            // Note name picker
            Picker("Note", selection: $note.name) {
                ForEach(availableNotes, id: \.self) { noteName in
                    Text(noteName).tag(noteName)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 80)

            // Octave picker
            Picker("Octave", selection: .init(
                get: { note.octave },
                set: { note = TuningNote(name: note.name, octave: $0) }
            )) {
                ForEach(availableOctaves, id: \.self) { octave in
                    Text("\(octave)").tag(octave)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 70)
        }
    }
}

#Preview {
    CustomTuningCreator(
        instrument: .guitar6,
        onSave: { _ in },
        onCancel: { }
    )
}
