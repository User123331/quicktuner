import SwiftUI

struct StringRailView: View {
    @Bindable var viewModel: TunerViewModel

    var body: some View {
        let notes = viewModel.tuningLibrary.selectedTuning?.notes ?? []

        HStack(spacing: 8) {
            // Display strings from low (right) to high (left) for standard guitar orientation
            // notes array is [String 1 (high), String 2, ..., String N (low)]
            // Display reversed: [String N (low), ..., String 2, String 1 (high)]
            let reversedNotes = Array(notes.enumerated().reversed())
            ForEach(reversedNotes, id: \.offset) { index, note in
                let displayStringNumber = notes.count - index
                let stringIndex = notes.count - index - 1
                StringButton(
                    stringNumber: displayStringNumber,
                    targetNote: note,
                    isTuned: viewModel.isStringTuned(stringIndex: stringIndex)
                )
                .onTapGesture {
                    viewModel.selectString(at: stringIndex)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct StringButton: View {
    let stringNumber: Int
    let targetNote: TuningNote
    let isTuned: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(targetNote.name)\(targetNote.octave)")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)

            Text("\(stringNumber)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            // Tuning indicator
            Circle()
                .fill(isTuned ? Color.green : Color.clear)
                .stroke(isTuned ? Color.green : Color.secondary, lineWidth: 1)
                .frame(width: 8, height: 8)
        }
        .frame(minWidth: 44)
        .padding(.vertical, 8)
        .background(isTuned ? Color.green.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isTuned ? Color.green.opacity(0.3) : Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    StringRailView(viewModel: TunerViewModel())
        .frame(width: 400)
        .padding()
}
