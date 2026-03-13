import SwiftUI

/// String rail showing target notes for selected tuning with glass button styling
struct StringRailView: View {
    @Bindable var viewModel: TunerViewModel

    var body: some View {
        let notes = viewModel.tuningLibrary.selectedTuning?.notes ?? []

        ScrollView(.horizontal, showsIndicators: false) {
            stringRailContent(notes: notes)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 24)  // Spacing above/below rail per CONTEXT.md
        .animation(AnimationStyles.stringSelection, value: viewModel.selectedStringIndex)
    }

    @ViewBuilder
    private func stringRailContent(notes: [TuningNote]) -> some View {
        let reversedNotes = Array(notes.enumerated().reversed())
        if #available(macOS 26.0, *) {
            GlassEffectContainer {
                HStack(spacing: 8) {
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
            }
        } else {
            HStack(spacing: 8) {
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
        }
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
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isTuned ? Color("InTuneGreen") : Color.clear, lineWidth: 1.5)
            )
            .glassButton(cornerRadius: 20)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .opacity(isSelected ? 1.0 : 0.7)
    }
}

// MARK: - Preview
#Preview {
    StringRailView(viewModel: TunerViewModel())
        .frame(width: 400)
        .padding()
}
