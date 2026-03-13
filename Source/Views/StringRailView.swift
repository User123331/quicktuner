import SwiftUI

/// String rail showing target notes for selected tuning with glass button styling.
/// Pills scale down automatically to fit 4–8 strings within the fixed 440pt window width.
struct StringRailView: View {
    @Bindable var viewModel: TunerViewModel

    // MARK: - Layout helpers

    /// Usable width = 440pt window − 24pt outer padding × 2 − 16pt inner padding × 2
    private let usableRailWidth: CGFloat = 360

    private var stringCount: Int {
        viewModel.tuningLibrary.selectedTuning?.notes.count ?? 6
    }

    private var pillSpacing: CGFloat {
        stringCount >= 7 ? 6 : 8
    }

    private var pillWidth: CGFloat {
        let totalSpacing = pillSpacing * CGFloat(max(stringCount - 1, 0))
        return (usableRailWidth - totalSpacing) / CGFloat(max(stringCount, 1))
    }

    private var pillFontSize: CGFloat {
        switch stringCount {
        case ..<6:  return 14
        case 6:     return 13
        default:    return 12
        }
    }

    // MARK: - Body

    var body: some View {
        let notes = viewModel.tuningLibrary.selectedTuning?.notes ?? []
        stringRailContent(notes: notes)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .animation(AnimationStyles.stringSelection, value: viewModel.selectedStringIndex)
    }

    @ViewBuilder
    private func stringRailContent(notes: [TuningNote]) -> some View {
        let reversedNotes = Array(notes.enumerated().reversed())
        if #available(macOS 26.0, *) {
            GlassEffectContainer {
                HStack(spacing: pillSpacing) {
                    ForEach(reversedNotes, id: \.offset) { item in
                        let index = item.offset
                        let note = item.element
                        let stringIndex = notes.count - index - 1
                        let isSelected = viewModel.selectedStringIndex == stringIndex
                        StringButton(
                            stringNumber: notes.count - index,
                            targetNote: note,
                            isTuned: viewModel.isStringTuned(stringIndex: stringIndex),
                            isSelected: isSelected,
                            pillWidth: pillWidth,
                            fontSize: pillFontSize
                        )
                        .onTapGesture {
                            viewModel.selectString(at: stringIndex)
                        }
                    }
                }
            }
        } else {
            HStack(spacing: pillSpacing) {
                ForEach(reversedNotes, id: \.offset) { item in
                    let index = item.offset
                    let note = item.element
                    let stringIndex = notes.count - index - 1
                    let isSelected = viewModel.selectedStringIndex == stringIndex
                    StringButton(
                        stringNumber: notes.count - index,
                        targetNote: note,
                        isTuned: viewModel.isStringTuned(stringIndex: stringIndex),
                        isSelected: isSelected,
                        pillWidth: pillWidth,
                        fontSize: pillFontSize
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
    let pillWidth: CGFloat
    let fontSize: CGFloat

    var body: some View {
        Text("\(targetNote.name)\(targetNote.octave)")
            .font(.system(size: fontSize, weight: isSelected ? .semibold : .medium, design: .rounded))
            .foregroundStyle(isSelected ? .primary : .secondary)
            .frame(width: pillWidth, height: 44)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isTuned ? Color.green : Color.clear, lineWidth: 1.5)
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
