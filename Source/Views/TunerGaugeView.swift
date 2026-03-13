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

    // Animation state - use animated values for Canvas rendering
    @State private var animatedCents: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        // Canvas as root view - no container, floats directly on window background
        Canvas { context, size in
            let center = CGPoint(
                x: size.width / 2,
                y: size.height - 40  // Position near bottom for semicircle
            )

            // Draw tick marks at key positions (subtle, no background arc)
            drawTickMarks(in: &context, center: center)

            // Draw needle based on animated cents value
            drawNeedle(in: &context, center: center, cents: animatedCents)

            // Draw in-tune glow with animated opacity
            if isInTune {
                drawInTuneGlow(in: &context, center: center, opacity: glowOpacity)
            }
        }
        .frame(width: 300, height: 180)
        .onChange(of: cents) { oldValue, newValue in
            withAnimation(AnimationStyles.needle) {
                animatedCents = newValue
            }
        }
        .onChange(of: isInTune) { _, newValue in
            if newValue {
                withAnimation(AnimationStyles.inTunePulse) {
                    glowOpacity = 1.0
                }
            } else {
                // Stop animation and reset immediately
                glowOpacity = 0.0
            }
        }
        .onAppear {
            animatedCents = cents
            glowOpacity = isInTune ? 1.0 : 0.0
        }
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
        // In-tune zone with gradient-style effect (multi-segment for smooth appearance)
        let inTuneAngle = 2.0 / 50.0 * 90.0  // 3.6 degrees from center

        // Create multi-segment gradient effect for in-tune zone
        // Opacity varies from center (bright) to edges (faded)
        let segments = 5
        for i in 0..<segments {
            let t = Double(i) / Double(segments - 1)  // 0 to 1
            let segmentAngle = inTuneAngle * 2 / Double(segments)
            let startAngle = Angle.degrees(-inTuneAngle + Double(i) * segmentAngle)
            let endAngle = Angle.degrees(-inTuneAngle + Double(i + 1) * segmentAngle)

            // Opacity varies from center (0.8) to edges (0.4)
            let opacity = 0.4 + 0.4 * (1 - abs(t - 0.5) * 2)

            let segmentPath = Path { path in
                path.addArc(
                    center: center,
                    radius: arcRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
            }

            context.stroke(
                segmentPath,
                with: .color(Color("InTuneGreen").opacity(opacity)),
                lineWidth: arcLineWidth
            )
        }

        // Warning zone markers: ±25 cents - draw as small arc segments
        for tickCents in [-25, 25] {
            let angle = angleForCents(Double(tickCents))

            // Draw warning indicator as a small arc segment
            let warnAngleDegrees = 5.0  // degrees
            let warnStart = Angle.radians(angle - warnAngleDegrees * .pi / 180)
            let warnEnd = Angle.radians(angle + warnAngleDegrees * .pi / 180)

            let warnPath = Path { path in
                path.addArc(
                    center: center,
                    radius: arcRadius,
                    startAngle: warnStart,
                    endAngle: warnEnd,
                    clockwise: false
                )
            }

            // Gradient-style warning indicator
            context.stroke(
                warnPath,
                with: .color(Color("WarningOrange").opacity(0.6)),
                lineWidth: arcLineWidth
            )
        }
    }

    private func drawTickMarks(in context: inout GraphicsContext, center: CGPoint) {
        let tickPositions = [0, -10, -50, 10, 50]

        for tickCents in tickPositions {
            let angle = angleForCents(Double(tickCents))
            let tickPath = tickPath(at: angle, center: center, radius: arcRadius)

            // Center tick is brighter and more prominent, others fade toward edges
            let isCenter = tickCents == 0
            let color: Color = isCenter ? .primary : .secondary
            let lineWidth: CGFloat = isCenter ? 3 : 2
            let opacity: Double = isCenter ? 1.0 : 0.7

            context.stroke(
                tickPath,
                with: .color(color.opacity(opacity)),
                lineWidth: lineWidth
            )
        }
    }

    private func drawNeedle(in context: inout GraphicsContext, center: CGPoint, cents: Double) {
        drawRefinedNeedle(in: &context, center: center, cents: cents)
    }

    private func drawRefinedNeedle(in context: inout GraphicsContext, center: CGPoint, cents: Double) {
        let clampedCents = max(minCents, min(maxCents, cents))
        let angle = angleForCents(clampedCents)

        // Triangle needle dimensions
        let needleBaseWidth: CGFloat = 8

        // Calculate tip position
        let tipX = center.x + cos(angle) * needleLength
        let tipY = center.y + sin(angle) * needleLength

        // Perpendicular angle for base width
        let perpAngle = angle + .pi / 2

        // Base points (at center, perpendicular to needle direction)
        let baseLeftX = center.x + cos(perpAngle) * (needleBaseWidth / 2)
        let baseLeftY = center.y + sin(perpAngle) * (needleBaseWidth / 2)
        let baseRightX = center.x - cos(perpAngle) * (needleBaseWidth / 2)
        let baseRightY = center.y - sin(perpAngle) * (needleBaseWidth / 2)

        // Create triangle path
        var needlePath = Path()
        needlePath.move(to: CGPoint(x: baseLeftX, y: baseLeftY))
        needlePath.addLine(to: CGPoint(x: tipX, y: tipY))
        needlePath.addLine(to: CGPoint(x: baseRightX, y: baseRightY))
        needlePath.closeSubpath()

        // Needle color based on cents deviation
        let needleColor: Color = {
            if abs(cents) <= 2 { return Color("InTuneGreen") }
            if abs(cents) <= 25 { return Color("WarningOrange") }
            return Color("ErrorRed")
        }()

        // Draw shadow first (offset slightly for depth)
        var shadowPath = needlePath
        shadowPath = shadowPath.offsetBy(dx: 1, dy: 2)
        context.fill(shadowPath, with: .color(.black.opacity(0.3)))

        // Draw needle
        context.fill(needlePath, with: .color(needleColor))

        // Draw center pivot
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

        // Pivot shadow ring for depth
        context.stroke(
            Path(ellipseIn: pivotRect.insetBy(dx: -2, dy: -2)),
            with: .color(.black.opacity(0.2)),
            lineWidth: 2
        )
    }

    private func drawInTuneGlow(in context: inout GraphicsContext, center: CGPoint, opacity: Double) {
        guard opacity > 0 else { return }

        let glowColor = Color("InTuneGreen")

        // Multiple glow rings for depth - inner bright to outer ambient
        let glowLayers: [(radius: CGFloat, width: CGFloat, alpha: Double)] = [
            (arcRadius - 4, arcLineWidth + 8, 0.8),   // Inner bright
            (arcRadius, arcLineWidth + 16, 0.5),      // Middle glow
            (arcRadius + 8, arcLineWidth + 24, 0.3),  // Outer aura
            (arcRadius + 16, arcLineWidth + 40, 0.15) // Ambient
        ]

        for layer in glowLayers {
            let arcPath = Path { path in
                path.addArc(
                    center: center,
                    radius: layer.radius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(90),
                    clockwise: false
                )
            }

            context.stroke(
                arcPath,
                with: .color(glowColor.opacity(opacity * layer.alpha)),
                lineWidth: layer.width
            )
        }

        // Add center highlight point for extra glow at the top
        let highlightRect = CGRect(
            x: center.x - 20,
            y: center.y - arcRadius - 10,
            width: 40,
            height: 40
        )
        context.fill(
            Path(ellipseIn: highlightRect),
            with: .color(glowColor.opacity(opacity * 0.4))
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
