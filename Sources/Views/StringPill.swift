import SwiftUI

struct StringPill: View {
    let index: Int              // 0-based index (displayed as 1-based)
    let noteName: String
    let octave: Int
    let isSelected: Bool
    let isTuned: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Note name + octave
                Text("\(noteName)\(octave)")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)

                // Underline highlight when selected
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(width: 28, height: 3)
                    .cornerRadius(1.5)

                // Checkmark when tuned
                if isTuned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                        .symbolRenderingMode(.multicolor)
                } else {
                    // Spacer to maintain consistent height
                    Color.clear
                        .frame(height: 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.secondary.opacity(0.15) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.secondary.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 12) {
        // Selected and tuned
        StringPill(
            index: 0,
            noteName: "E",
            octave: 2,
            isSelected: true,
            isTuned: true,
            action: {}
        )

        // Selected not tuned
        StringPill(
            index: 1,
            noteName: "A",
            octave: 2,
            isSelected: true,
            isTuned: false,
            action: {}
        )

        // Not selected, tuned
        StringPill(
            index: 2,
            noteName: "D",
            octave: 3,
            isSelected: false,
            isTuned: true,
            action: {}
        )

        // Not selected, not tuned
        StringPill(
            index: 3,
            noteName: "G",
            octave: 3,
            isSelected: false,
            isTuned: false,
            action: {}
        )
    }
    .padding()
}
