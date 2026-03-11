import SwiftUI

/// Cents readout view displaying pitch deviation as integer with sign
/// Uses SF Mono font for numeric stability and color-codes based on deviation
struct CentsReadoutView: View {
    let cents: Double?

    var body: some View {
        Group {
            if let cents = cents {
                let intCents = Int(round(cents))
                let sign = intCents > 0 ? "+" : ""
                Text("\(sign)\(intCents)")
                    .font(.system(.title2, design: .monospaced).weight(.medium))
                    .foregroundColor(colorForCents(intCents))
            } else {
                Text("--")
                    .font(.system(.title2, design: .monospaced).weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 60)
        .monospacedDigit()
    }

    private func colorForCents(_ cents: Int) -> Color {
        let absCents = abs(cents)
        if absCents <= 2 {
            return .green
        } else if absCents <= 25 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CentsReadoutView(cents: nil)           // --
        CentsReadoutView(cents: 0)             // 0 (green)
        CentsReadoutView(cents: -1.5)          // -2 (green)
        CentsReadoutView(cents: 15.7)          // +16 (yellow)
        CentsReadoutView(cents: -42.3)         // -42 (red)
    }
    .padding()
}
