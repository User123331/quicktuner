import SwiftUI

/// Semicircular tuner gauge with proper geometry, animated needle, and tick marks.
/// Uses SwiftUI geometry and rotationEffect for correct animation.
struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool

    // Layout
    private let gaugeRadius: CGFloat = 110
    private let needleLength: CGFloat = 95

    // Tick definitions
    private let majorTicks: [Int] = [-50, -30, -10, 0, 10, 30, 50]
    private let minorTicks: [Int] = [-40, -20, -5, 5, 20, 40]

    // Animation state
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // 1. Background arc (static)
            arcBackground

            // 2. In-tune zone arc
            inTuneZoneArc

            // 3. Tick marks (static)
            tickMarksLayer

            // 4. Animated needle
            needleLayer

            // 5. Center pivot
            pivotDot

            // 6. In-tune glow
            if isInTune {
                inTuneGlow
            }
        }
        .frame(width: 300, height: 170)
        // Offset everything so the pivot is near the bottom of the frame
        .offset(y: 20)
        .onChange(of: isInTune) { _, newValue in
            if newValue {
                withAnimation(AnimationStyles.inTunePulse) {
                    glowOpacity = 1.0
                }
            } else {
                glowOpacity = 0.0
            }
        }
        .onAppear {
            glowOpacity = isInTune ? 1.0 : 0.0
        }
    }

    // MARK: - Angle Conversion

    /// Convert cents to a rotation angle.
    /// 0 cents = straight up (0 degrees rotation from vertical).
    /// -50 cents = full left (-90 degrees). +50 cents = full right (+90 degrees).
    /// Works because the needle starts pointing up, and .rotationEffect rotates CW.
    private func angle(for cents: Double) -> Angle {
        let clamped = max(-50, min(50, cents))
        return .degrees(clamped / 50.0 * 90.0)
    }

    // MARK: - Sub-views

    /// Thin semicircular arc as the gauge track
    private var arcBackground: some View {
        Circle()
            .trim(from: 0.25, to: 0.75) // Top half of circle
            .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
            .frame(width: gaugeRadius * 2, height: gaugeRadius * 2)
            .rotationEffect(.degrees(180)) // Flip so open side faces down
    }

    /// Green zone arc near center (+-5 cents)
    private var inTuneZoneArc: some View {
        let zoneFraction: CGFloat = 5.0 / 50.0 * 0.25 // 5 cents out of 50 = 10% of semicircle half
        return Circle()
            .trim(from: 0.5 - zoneFraction, to: 0.5 + zoneFraction)
            .stroke(Color.green.opacity(0.4), lineWidth: 6)
            .frame(width: gaugeRadius * 2, height: gaugeRadius * 2)
            .rotationEffect(.degrees(180))
    }

    /// All tick marks rendered as rotated rectangles
    private var tickMarksLayer: some View {
        ZStack {
            ForEach(majorTicks, id: \.self) { tickCents in
                let isCenter = tickCents == 0
                Rectangle()
                    .fill(isCenter ? Color.primary : Color.secondary.opacity(0.7))
                    .frame(
                        width: isCenter ? 3 : 2,
                        height: isCenter ? 16 : 12
                    )
                    .offset(y: -(gaugeRadius + 6)) // Place just outside the arc
                    .rotationEffect(angle(for: Double(tickCents)), anchor: .center)
            }

            ForEach(minorTicks, id: \.self) { tickCents in
                Rectangle()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 1, height: 8)
                    .offset(y: -(gaugeRadius + 6))
                    .rotationEffect(angle(for: Double(tickCents)), anchor: .center)
            }
        }
    }

    /// The needle: a tapered triangle pointing up, rotated by cents.
    /// offset(y: -needleLength/2) moves the needle up so its base sits at the ZStack center.
    /// rotationEffect with .bottom anchor rotates around the needle's base point.
    private var needleLayer: some View {
        NeedleShape()
            .fill(needleColor)
            .frame(width: 10, height: needleLength)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 2)
            .rotationEffect(angle(for: cents), anchor: .bottom)
            .offset(y: -(needleLength / 2))
            .animation(AnimationStyles.needle, value: cents)
    }

    /// Small circle at the pivot point
    private var pivotDot: some View {
        ZStack {
            Circle()
                .fill(Color.primary)
                .frame(width: 12, height: 12)
            Circle()
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                .frame(width: 16, height: 16)
        }
    }

    /// Glow effect when in tune
    private var inTuneGlow: some View {
        Circle()
            .trim(from: 0.25, to: 0.75)
            .stroke(
                Color.green.opacity(glowOpacity * 0.6),
                lineWidth: 20
            )
            .blur(radius: 10)
            .frame(width: gaugeRadius * 2, height: gaugeRadius * 2)
            .rotationEffect(.degrees(180))
    }

    /// Needle color based on deviation
    private var needleColor: Color {
        let absCents = abs(cents)
        if absCents <= 2 { return .green }
        if absCents <= 25 { return .orange }
        return .red
    }
}

/// Custom triangle shape for the needle (tapered: wide at base, pointed at tip)
struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseWidth: CGFloat = rect.width
        let tipWidth: CGFloat = 2 // Pointed tip

        // Triangle: wide base at bottom, narrow tip at top
        path.move(to: CGPoint(x: rect.midX - baseWidth / 2, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX - tipWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + tipWidth / 2, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX + baseWidth / 2, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        // Flat
        TunerGaugeView(cents: -15, isInTune: false)

        // In tune
        TunerGaugeView(cents: 1.5, isInTune: true)

        // Sharp
        TunerGaugeView(cents: 35, isInTune: false)

        // Center
        TunerGaugeView(cents: 0, isInTune: false)
    }
    .padding()
}
