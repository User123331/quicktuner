import SwiftUI

/// Cents readout view displaying pitch deviation as integer with sign
/// Uses SF Mono font for numeric stability and color-codes based on deviation
struct CentsReadoutView: View {
    let cents: Double?

    private var centsColor: Color {
        guard let cents = cents else { return .secondary }
        let absCents = abs(Int(round(cents)))
        if absCents < 5 { return Color("InTuneGreen") }
        if absCents < 20 { return Color("WarningOrange") }
        return Color("ErrorRed")
    }

    var body: some View {
        Group {
            if let cents = cents {
                let intCents = Int(round(cents))
                let sign = intCents > 0 ? "+" : ""
                Text("\(sign)\(intCents)")
                    .font(.system(size: 24, weight: .regular, design: .monospaced))
                    .foregroundColor(centsColor)
            } else {
                Text("--")
                    .font(.system(size: 24, weight: .regular, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .frame(minWidth: 60)
        .monospacedDigit()
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
