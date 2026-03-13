import SwiftUI

/// Segmented VU meter with dynamic width filling 90% of container.
/// Segment count scales based on available width while maintaining
/// the 60% green, 25% yellow, 15% red color zone ratio.
struct InputLevelMeter: View {
    let level: Float  // 0.0 to 1.0

    private let segmentSpacing: CGFloat = 2
    private let minSegmentWidth: CGFloat = 8
    private let maxSegments = 40  // Cap to prevent too many tiny segments
    private let segmentHeight: CGFloat = 14

    var body: some View {
        GeometryReader { geometry in
            let targetWidth = geometry.size.width * 0.9  // 90% of container
            let segmentCount = calculateSegmentCount(for: targetWidth)
            let segmentWidth = calculateSegmentWidth(
                totalWidth: targetWidth,
                segmentCount: segmentCount
            )
            let greenCount = Int(Float(segmentCount) * 0.6)
            let yellowCount = Int(Float(segmentCount) * 0.25)

            HStack(spacing: segmentSpacing) {
                ForEach(0..<segmentCount, id: \.self) { i in
                    let threshold = Float(i + 1) / Float(segmentCount)
                    let isLit = level >= threshold

                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(
                            color(for: i, greenCount: greenCount, yellowCount: yellowCount)
                                .opacity(isLit ? 1.0 : 0.12)
                        )
                        .frame(width: segmentWidth, height: segmentHeight)
                }
            }
            .frame(width: targetWidth)  // Constrain to 90%
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(height: segmentHeight)  // Fixed height for GeometryReader
        .animation(.linear(duration: 0.08), value: level)
    }

    // MARK: - Private Helpers

    private func calculateSegmentCount(for width: CGFloat) -> Int {
        let maxPossible = Int((width + segmentSpacing) / (minSegmentWidth + segmentSpacing))
        return min(max(maxPossible, 10), maxSegments)  // Min 10, max 40
    }

    private func calculateSegmentWidth(totalWidth: CGFloat, segmentCount: Int) -> CGFloat {
        (totalWidth - segmentSpacing * CGFloat(segmentCount - 1)) / CGFloat(segmentCount)
    }

    private func color(for index: Int, greenCount: Int, yellowCount: Int) -> Color {
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