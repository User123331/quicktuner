import SwiftUI

/// Displays the current reference pitch in "A4 = 432 Hz" format
/// Used below the cents readout on the main tuner UI
struct ReferencePitchDisplay: View {
    let referencePitch: Double

    var body: some View {
        Text("A4 = \(referencePitch, specifier: "%.1f") Hz")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
    }
}

// MARK: - Preview

#Preview("Standard 440 Hz") {
    ReferencePitchDisplay(referencePitch: 440.0)
        .padding()
}

#Preview("Alternative 432 Hz") {
    ReferencePitchDisplay(referencePitch: 432.0)
        .padding()
}

#Preview("Historical 420 Hz") {
    ReferencePitchDisplay(referencePitch: 420.0)
        .padding()
}
