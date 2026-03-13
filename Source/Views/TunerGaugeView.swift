import SwiftUI

/// 240° speedometer-style tuner gauge with trig-based tick marks, numeric labels,
/// and a two-shape needle (NeedleShaft + CounterweightShape).
struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool

    // Layout
    private let gaugeRadius: CGFloat = 110
    private let needleLength: CGFloat = 90       // shaft above pivot
    private let counterweightLength: CGFloat = 18 // stub below pivot
    private let labelRadius: CGFloat = 128        // gaugeRadius + 18

    // Tick definitions
    private let majorTicks: [Int] = [-50, -25, 0, 25, 50]
    private let minorTicks: [Int] = [-40, -30, -20, -10, -5, 5, 10, 20, 30, 40]

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

            // 4. Tick labels
            tickLabelsLayer

            // 5. Animated needle
            needleLayer

            // 6. Center pivot
            pivotDot

            // 7. In-tune glow
            if isInTune {
                inTuneGlow
            }
        }
        .frame(width: 300, height: 220)  // increased from 170 to 220 for label clearance
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

    /// Convert cents to a rotation angle for the needle.
    /// 0 cents = straight up (0 degrees rotation from vertical).
    /// -50 cents = full left (-90 degrees). +50 cents = full right (+90 degrees).
    /// Works because the needle starts pointing up, and .rotationEffect rotates CW.
    func angle(for cents: Double) -> Angle {
        let clamped = max(-50, min(50, cents))
        return .degrees(clamped / 50.0 * 90.0)
    }

    // MARK: - Arc Geometry

    /// Maps cents to degrees from vertical for arc element placement.
    /// ±50¢ → ±120° (arc endpoints). Different from needle which uses ±90°.
    internal func arcAngle(for cents: Double) -> Double {
        return cents / 50.0 * 120.0
    }

    /// Returns position relative to ZStack center (which is the gauge pivot).
    /// Positive x = right, negative y = up (SwiftUI y-axis flipped).
    internal func tickPosition(cents: Double, radius: CGFloat) -> CGPoint {
        let rad = arcAngle(for: cents) * .pi / 180.0
        return CGPoint(
            x: radius * sin(rad),
            y: -radius * cos(rad)
        )
    }

    // MARK: - Sub-views

    /// 240° arc as the gauge track (trim 0.167→0.833 + 180° rotation = open gap at bottom)
    private var arcBackground: some View {
        Circle()
            .trim(from: 0.167, to: 0.833)  // 240° = 2/3 of circle
            .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
            .frame(width: gaugeRadius * 2, height: gaugeRadius * 2)
            .rotationEffect(.degrees(180))  // flip: open gap faces down
    }

    /// Green zone arc near center (±2 cents)
    private var inTuneZoneArc: some View {
        // ±2¢ zone. arcCenter = (0.167 + 0.833) / 2 = 0.5 (top of arc after 180° rotation)
        // 2¢ in 240° arc: 2/50 * 120 = 4.8° → 4.8/360 = 0.01333 fraction
        let zoneHalfFraction = CGFloat(2.0 / 50.0 * 120.0 / 360.0)  // ~0.01333
        return Circle()
            .trim(from: 0.5 - zoneHalfFraction, to: 0.5 + zoneHalfFraction)
            .stroke(Color.green.opacity(0.4), lineWidth: 6)
            .frame(width: gaugeRadius * 2, height: gaugeRadius * 2)
            .rotationEffect(.degrees(180))
    }

    /// All tick marks rendered using trig-based Path approach
    private var tickMarksLayer: some View {
        ZStack {
            // Draw each major tick as a Path from inner radius to outer radius
            ForEach(majorTicks, id: \.self) { tickCents in
                let isCenter = tickCents == 0
                let innerR = gaugeRadius - 10
                let outerR = gaugeRadius + (isCenter ? 10 : 8)
                let inner = tickPosition(cents: Double(tickCents), radius: innerR)
                let outer = tickPosition(cents: Double(tickCents), radius: outerR)
                Path { p in
                    p.move(to: inner)
                    p.addLine(to: outer)
                }
                .stroke(
                    isCenter ? Color.primary : Color.secondary.opacity(0.7),
                    style: StrokeStyle(lineWidth: isCenter ? 3 : 2, lineCap: .round)
                )
            }

            ForEach(minorTicks, id: \.self) { tickCents in
                let innerR = gaugeRadius - 6
                let outerR = gaugeRadius + 4
                let inner = tickPosition(cents: Double(tickCents), radius: innerR)
                let outer = tickPosition(cents: Double(tickCents), radius: outerR)
                Path { p in
                    p.move(to: inner)
                    p.addLine(to: outer)
                }
                .stroke(Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, lineCap: .round))
            }
        }
    }

    /// Numeric labels at major tick positions
    private var tickLabelsLayer: some View {
        ZStack {
            ForEach([-50, -25, 0, 25, 50], id: \.self) { tickCents in
                let pos = tickPosition(cents: Double(tickCents), radius: labelRadius)
                let angleDeg = arcAngle(for: Double(tickCents))
                let label = tickCents == 0 ? "0" : (tickCents > 0 ? "+\(tickCents)" : "\(tickCents)")
                Text(label)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.secondary)
                    .rotationEffect(.degrees(angleDeg))  // tangential to arc
                    .offset(x: pos.x, y: pos.y)
            }
        }
    }

    /// Two-shape needle: thin NeedleShaft above pivot + teardrop CounterweightShape below
    /// NeedleShaft (above pivot) uses anchor: .bottom — rotates around bottom edge (the pivot)
    /// CounterweightShape (below pivot) uses anchor: .top — rotates around top edge (the pivot)
    private var needleLayer: some View {
        ZStack {
            NeedleShaft()
                .fill(needleColor)
                .frame(width: 6, height: needleLength)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                .offset(y: -(needleLength / 2))
                .rotationEffect(angle(for: cents), anchor: .bottom)
                .animation(AnimationStyles.needle, value: cents)

            CounterweightShape()
                .fill(needleColor)
                .frame(width: 10, height: counterweightLength)
                .offset(y: counterweightLength / 2)
                .rotationEffect(angle(for: cents), anchor: .top)
                .animation(AnimationStyles.needle, value: cents)
        }
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
            .trim(from: 0.167, to: 0.833)
            .stroke(Color.green.opacity(glowOpacity * 0.6), lineWidth: 20)
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

/// Thin tapered shaft above the pivot. Drawn in a rect where maxY is at the pivot.
/// rotationEffect(angle, anchor: .bottom) rotates around the bottom edge (pivot).
struct NeedleShaft: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Tip at top (narrow), base at bottom (wider, at pivot)
        p.move(to: CGPoint(x: rect.midX - 0.5, y: rect.minY))      // tip left
        p.addLine(to: CGPoint(x: rect.midX + 0.5, y: rect.minY))   // tip right
        p.addLine(to: CGPoint(x: rect.midX + 1.5, y: rect.maxY))   // base right
        p.addLine(to: CGPoint(x: rect.midX - 1.5, y: rect.maxY))   // base left
        p.closeSubpath()
        return p
    }
}

/// Teardrop counterweight below the pivot. Drawn in a rect where minY is at the pivot.
/// rotationEffect(angle, anchor: .top) rotates around the top edge (pivot).
struct CounterweightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX - 1.5, y: rect.minY))       // top-left (at pivot)
        p.addLine(to: CGPoint(x: rect.midX + 1.5, y: rect.minY))    // top-right
        p.addLine(to: CGPoint(x: rect.midX + 4, y: rect.maxY - 3))  // widen toward bottom
        p.addQuadCurve(                                               // rounded bottom
            to: CGPoint(x: rect.midX - 4, y: rect.maxY - 3),
            control: CGPoint(x: rect.midX, y: rect.maxY + 1)
        )
        p.closeSubpath()
        return p
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
