import SwiftUI

/// String rail showing target notes for selected tuning with glass button styling
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
                let isSelected = viewModel.selectedStringIndex == stringIndex
                StringButton(
                    stringNumber: displayStringNumber,
                    targetNote: note,
                    isTuned: viewModel.isStringTuned(stringIndex: stringIndex),
                    isSelected: isSelected
                )
                .onTapGesture {
                    viewModel.selectString(at: stringIndex)
                }
            }
        }
        .padding(.vertical, 24)  // Spacing above/below rail per CONTEXT.md
        .animation(AnimationStyles.stringSelection, value: viewModel.selectedStringIndex)
    }
}

struct StringButton: View {
    let stringNumber: Int
    let targetNote: TuningNote
    let isTuned: Bool
    let isSelected: Bool

    var body: some View {
        Text("\(targetNote.name)\(targetNote.octave)")
            .font(.system(size: 14, weight: isSelected ? .semibold : .medium, design: .rounded))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .frame(minWidth: 36, minHeight: 36)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.primary.opacity(0.15) : Color.primary.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isTuned ? Color("InTuneGreen") : (isSelected ? Color.primary.opacity(0.3) : Color.clear), lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    StringRailView(viewModel: TunerViewModel())
        .frame(width: 400)
        .padding()
}
