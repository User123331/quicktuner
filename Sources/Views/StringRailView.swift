import SwiftUI

struct StringRailView: View {
    @Binding var selectedIndex: Int
    let strings: [StringInfo]
    let tunedIndices: Set<Int>

    var body: some View {
        HStack(spacing: 8) {
            ForEach(strings.indices, id: \.self) { index in
                let stringInfo = strings[index]
                StringPill(
                    index: index,
                    noteName: stringInfo.note.name,
                    octave: stringInfo.note.octave,
                    isSelected: selectedIndex == index,
                    isTuned: tunedIndices.contains(index),
                    action: {
                        selectedIndex = index
                    }
                )
            }
        }
        .focusable()
        .onKeyPress(.leftArrow) {
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return .handled
        }
        .onKeyPress(.rightArrow) {
            if selectedIndex < strings.count - 1 {
                selectedIndex += 1
            }
            return .handled
        }
        .onKeyPress(characters: .decimalDigits) { keyPress in
            if let digit = Int(keyPress.characters),
               digit >= 1 && digit <= strings.count {
                selectedIndex = digit - 1  // Convert 1-based to 0-based
                return .handled
            }
            return .ignored
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var selectedIndex = 0

    let mockStrings = [
        StringInfo(id: 1, note: Note(name: "E", octave: 2, cents: 0, frequency: 82.41), isTuned: true),
        StringInfo(id: 2, note: Note(name: "A", octave: 2, cents: 0, frequency: 110.00), isTuned: false),
        StringInfo(id: 3, note: Note(name: "D", octave: 3, cents: 0, frequency: 146.83), isTuned: false),
        StringInfo(id: 4, note: Note(name: "G", octave: 3, cents: 0, frequency: 196.00), isTuned: true),
        StringInfo(id: 5, note: Note(name: "B", octave: 3, cents: 0, frequency: 246.94), isTuned: false),
        StringInfo(id: 6, note: Note(name: "E", octave: 4, cents: 0, frequency: 329.63), isTuned: false)
    ]

    VStack {
        Text("Selected: String \(selectedIndex + 1)")
            .font(.caption)
            .foregroundColor(.secondary)

        StringRailView(
            selectedIndex: $selectedIndex,
            strings: mockStrings,
            tunedIndices: [0, 3]
        )
    }
    .padding()
}
