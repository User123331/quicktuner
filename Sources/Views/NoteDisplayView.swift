import SwiftUI

/// Large note name display with octave
/// Uses SF Pro Rounded font for modern appearance
struct NoteDisplayView: View {
    let noteName: String?
    let isInTune: Bool

    var body: some View {
        Group {
            if let noteName = noteName, !noteName.isEmpty {
                Text(noteName)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(isInTune ? .green : .primary)
            } else {
                Text("--")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .animation(.smooth, value: isInTune)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        NoteDisplayView(noteName: "E2", isInTune: false)
        NoteDisplayView(noteName: "A2", isInTune: true)
        NoteDisplayView(noteName: nil, isInTune: false)
    }
    .padding()
}
