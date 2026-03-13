import SwiftUI

/// Cents readout view displaying pitch deviation as integer with sign and unit label.
/// Uses SF Mono font for numeric stability and color-codes based on deviation.
struct CentsReadoutView: View {
    let cents: Double?

    private var centsColor: Color {
        guard let cents = cents else { return .secondary }
        let absCents = abs(cents)
        if absCents < 3 { return Color("InTuneGreen") }
        if absCents < 15 { return Color("WarningOrange") }
        return Color("ErrorRed")
    }

    var body: some View {
        HStack(spacing: 4) {
            if let cents = cents {
                let intCents = Int(round(cents))
                let sign = intCents > 0 ? "+" : ""
                Text("\(sign)\(intCents)")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(centsColor)
                Text("cents")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            } else {
                Text("--")
                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 100)
        .monospacedDigit()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        CentsReadoutView(cents: nil)           // --
        CentsReadoutView(cents: 0)             // 0 cents (green)
        CentsReadoutView(cents: -1.5)          // -2 cents (green)
        CentsReadoutView(cents: 15.7)          // +16 cents (red)
        CentsReadoutView(cents: -42.3)         // -42 cents (red)
        CentsReadoutView(cents: 8.0)           // +8 cents (orange)
    }
    .padding()
}
