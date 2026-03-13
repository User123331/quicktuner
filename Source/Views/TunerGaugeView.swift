import SwiftUI

/// Horizontal linear tuner gauge with sliding needle.
/// Clean, simple design using only built-in SwiftUI shapes.
struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool

    // Layout constants
    private let gaugeWidth: CGFloat = 280
    private let gaugeHeight: CGFloat = 8
    private let needleHeight: CGFloat = 24
    private let majorTicks: [Int] = [-50, -25, 0, 25, 50]

    /// Map cents (-50 to +50) to horizontal offset from center
    func needleOffset(for cents: Double) -> CGFloat {
        let clamped = max(-50, min(50, cents))
        // -50 -> -gaugeWidth/2, 0 -> 0, +50 -> +gaugeWidth/2
        return (clamped / 50.0) * (gaugeWidth / 2)
    }

    var body: some View {
        VStack(spacing: 8) {
            // Gauge track with needle and ticks
            ZStack {
                // Background track
                trackBackground

                // Color zones (green/yellow/red)
                colorZones

                // Center indicator
                centerIndicator

                // Tick marks
                tickMarks

                // Sliding needle
                needle
            }
            .frame(width: gaugeWidth, height: needleHeight)

            // Labels below gauge
            labels
        }
    }

    // MARK: - Subviews

    private var trackBackground: some View {
        RoundedRectangle(cornerRadius: gaugeHeight / 2)
            .fill(Color.secondary.opacity(0.15))
            .frame(width: gaugeWidth, height: gaugeHeight)
    }

    private var colorZones: some View {
        // Zones: red (outer), orange (middle), green (center)
        // -50 to -25: red (25%)
        // -25 to -2: orange (23%)
        // -2 to +2: green (4%)
        // +2 to +25: orange (23%)
        // +25 to +50: red (25%)
        GeometryReader { geometry in
            let width = geometry.size.width
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: width * 0.25)

                Rectangle()
                    .fill(Color.orange.opacity(0.25))
                    .frame(width: width * 0.23)

                Rectangle()
                    .fill(Color.green.opacity(0.35))
                    .frame(width: width * 0.04)

                Rectangle()
                    .fill(Color.orange.opacity(0.25))
                    .frame(width: width * 0.23)

                Rectangle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: width * 0.25)
            }
            .clipShape(RoundedRectangle(cornerRadius: gaugeHeight / 2))
        }
        .frame(width: gaugeWidth, height: gaugeHeight)
    }

    private var centerIndicator: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.5))
            .frame(width: 2, height: gaugeHeight + 4)
    }

    private var tickMarks: some View {
        ForEach(majorTicks, id: \.self) { tick in
            Rectangle()
                .fill(Color.primary.opacity(tick == 0 ? 0.6 : 0.3))
                .frame(width: tick == 0 ? 2 : 1, height: tick == 0 ? 12 : 8)
                .offset(x: (CGFloat(tick) / 50.0) * (gaugeWidth / 2))
        }
    }

    private var needle: some View {
        Capsule()
            .fill(needleColor)
            .frame(width: 3, height: needleHeight)
            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            .offset(x: needleOffset(for: cents))
            .animation(AnimationStyles.needle, value: cents)
    }

    private var labels: some View {
        HStack(spacing: 0) {
            ForEach(majorTicks, id: \.self) { tick in
                Text(tick == 0 ? "0" : (tick > 0 ? "+\(tick)" : "\(tick)"))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: gaugeWidth)
    }

    // MARK: - Needle Color

    private var needleColor: Color {
        let absCents = abs(cents)
        if absCents <= 2 { return .green }
        if absCents <= 25 { return .orange }
        return .red
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        // Flat
        TunerGaugeView(cents: -15, isInTune: false)

        // In tune
        TunerGaugeView(cents: 0.5, isInTune: true)

        // Sharp
        TunerGaugeView(cents: 35, isInTune: false)

        // Center
        TunerGaugeView(cents: 0, isInTune: false)

        // Far left
        TunerGaugeView(cents: -50, isInTune: false)

        // Far right
        TunerGaugeView(cents: 50, isInTune: false)
    }
    .padding()
}
