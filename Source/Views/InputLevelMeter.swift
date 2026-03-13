import SwiftUI

/// Segmented VU meter with fixed green/yellow/red color zones.
/// Displays audio input level as discrete illuminated blocks.
struct InputLevelMeter: View {
    let level: Float  // 0.0 to 1.0

    private let segmentCount = 20
    private let greenCount = 12   // First 60% = green (safe)
    private let yellowCount = 5   // Next 25% = yellow (hot)
    // Remaining 3 = red (15%, clip warning)

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segmentCount, id: \.self) { i in
                let threshold = Float(i + 1) / Float(segmentCount)
                let isLit = level >= threshold

                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color(for: i).opacity(isLit ? 1.0 : 0.12))
                    .frame(height: 14)
            }
        }
        .animation(.linear(duration: 0.08), value: level)
    }

    private func color(for index: Int) -> Color {
        if index < greenCount { return .green }
        if index < greenCount + yellowCount { return .yellow }
        return .red
    }
}

#Preview {
    VStack(spacing: 20) {
        InputLevelMeter(level: 0.0)
        InputLevelMeter(level: 0.3)
        InputLevelMeter(level: 0.6)
        InputLevelMeter(level: 0.85)
        InputLevelMeter(level: 1.0)
    }
    .padding()
    .frame(width: 300)
}
