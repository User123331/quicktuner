import SwiftUI

/// Canvas-based tuner gauge with needle, tick marks, and color zones
/// Displays pitch deviation as a semicircular arc with visual feedback
struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool

    // Arc spans ±50 cents (one semitone in each direction)
    private let minCents = -50.0
    private let maxCents = 50.0

    // Visual configuration
    private let arcRadius: CGFloat = 120
    private let arcLineWidth: CGFloat = 12
    private let tickLength: CGFloat = 10
    private let needleLength: CGFloat = 100
    private let needleLineWidth: CGFloat = 3

    var body: some View {
        // Wrap Canvas in a glass card container (NOT applying glass directly to Canvas)
        VStack {
            Canvas { context, size in
                let center = CGPoint(
                    x: size.width / 2,
                    y: size.height - 40  // Position near bottom for semicircle
                )

                // Draw background arc
                drawBackgroundArc(in: &context, center: center)

                // Draw color zones (green ±2¢, yellow ±25¢ markers)
                drawColorZones(in: &context, center: center)

                // Draw tick marks at key positions
                drawTickMarks(in: &context, center: center)

                // Draw needle based on current cents
                drawNeedle(in: &context, center: center)

                // Draw in-tune indicator
                if isInTune {
                    drawInTuneGlow(in: &context, center: center)
                }
            }
            .frame(width: 300, height: 180)
        }
        .glassCard(cornerRadius: 24)  // Glass effect on container, not Canvas
    }

    // MARK: - Drawing Functions

    private func drawBackgroundArc(in context: inout GraphicsContext, center: CGPoint) {
        let arcPath = Path { path in
            path.addArc(
                center: center,
                radius: arcRadius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
        }
        context.stroke(
            arcPath,
            with: .color(.secondary.opacity(0.3)),
            lineWidth: arcLineWidth
        )
    }

    private func drawColorZones(in context: inout GraphicsContext, center: CGPoint) {
        // Green zone: ±2 cents (in-tune range)
        let inTuneAngle = 2.0 / 50.0 * 90.0  // 3.6 degrees from center
        let inTuneStart = Angle.degrees(-inTuneAngle)
        let inTuneEnd = Angle.degrees(inTuneAngle)

        let inTunePath = Path { path in
            path.addArc(
                center: center,
                radius: arcRadius,
                startAngle: inTuneStart,
                endAngle: inTuneEnd,
                clockwise: false
            )
        }
        context.stroke(
            inTunePath,
            with: .color(.green.opacity(0.6)),
            lineWidth: arcLineWidth
        )

        // Yellow zone markers: ±25 cents
        for tickCents in [-25, 25] {
            let angle = angleForCents(Double(tickCents))
            let tickPath = tickPath(at: angle, center: center, radius: arcRadius)
            context.stroke(tickPath, with: .color(.yellow.opacity(0.7)), lineWidth: 3)
        }
    }

    private func drawTickMarks(in context: inout GraphicsContext, center: CGPoint) {
        let tickPositions = [0, -10, -50, 10, 50]

        for tickCents in tickPositions {
            let angle = angleForCents(Double(tickCents))
            let tickPath = tickPath(at: angle, center: center, radius: arcRadius)

            // Center tick (0 cents) is white, others are gray
            let color: Color = tickCents == 0 ? .primary : .secondary
            let lineWidth: CGFloat = tickCents == 0 ? 3 : 2

            context.stroke(tickPath, with: .color(color), lineWidth: lineWidth)
        }
    }

    private func drawNeedle(in context: inout GraphicsContext, center: CGPoint) {
        let clampedCents = max(minCents, min(maxCents, cents))
        let angle = angleForCents(clampedCents)

        // Calculate needle tip position
        let tipX = center.x + cos(angle) * needleLength
        let tipY = center.y + sin(angle) * needleLength

        var needlePath = Path()
        needlePath.move(to: center)
        needlePath.addLine(to: CGPoint(x: tipX, y: tipY))

        // Color based on cents deviation
        let needleColor: Color = {
            if abs(cents) <= 2 { return .green }
            if abs(cents) <= 25 { return .yellow }
            return .red
        }()

        context.stroke(
            needlePath,
            with: .color(needleColor),
            lineWidth: needleLineWidth
        )

        // Draw center pivot dot
        let pivotSize: CGFloat = 10
        let pivotRect = CGRect(
            x: center.x - pivotSize/2,
            y: center.y - pivotSize/2,
            width: pivotSize,
            height: pivotSize
        )
        context.fill(
            Path(ellipseIn: pivotRect),
            with: .color(.primary)
        )
    }

    private func drawInTuneGlow(in context: inout GraphicsContext, center: CGPoint) {
        // Phase 2: Green stroke as placeholder for Phase 4 Liquid Glass glow
        let arcPath = Path { path in
            path.addArc(
                center: center,
                radius: arcRadius,
                startAngle: .degrees(-90),
                endAngle: .degrees(90),
                clockwise: false
            )
        }
        context.stroke(
            arcPath,
            with: .color(.green.opacity(0.8)),
            lineWidth: arcLineWidth + 4
        )
    }

    // MARK: - Helper Functions

    private func angleForCents(_ cents: Double) -> CGFloat {
        // Map cents (-50 to +50) to angle (-90° to +90°)
        // -50 cents = -90° (left), 0 cents = 0° (center), +50 cents = +90° (right)
        let normalized = cents / 50.0  // -1.0 to 1.0
        let degrees = normalized * 90.0
        return CGFloat(degrees * .pi / 180.0)
    }

    private func tickPath(at angle: CGFloat, center: CGPoint, radius: CGFloat) -> Path {
        let innerRadius = radius - tickLength
        let outerRadius = radius + tickLength

        let startX = center.x + cos(angle) * innerRadius
        let startY = center.y + sin(angle) * innerRadius
        let endX = center.x + cos(angle) * outerRadius
        let endY = center.y + sin(angle) * outerRadius

        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))
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
