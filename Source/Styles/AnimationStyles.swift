import SwiftUI

// MARK: - Animation Styles

/// Predefined spring animation constants for consistent motion throughout the app.
///
/// These presets provide the appropriate physics for different UI interactions,
/// from precision instrument movements to playful UI feedback.
///
/// ## Usage Patterns
///
/// ### View Animation (automatic on value change):
/// ```swift
/// NeedleView()
///     .animation(AnimationStyles.needle, value: pitchDeviation)
/// ```
///
/// ### Explicit Animation (triggered programmatically):
/// ```swift
/// withAnimation(AnimationStyles.stringSelection) {
///     selectedString = newString
/// }
/// ```
///
/// ### State-Based Animation:
/// ```swift
/// GaugeView()
///     .animation(isInTune ? AnimationStyles.inTunePulse : .default, value: isInTune)
/// ```
enum AnimationStyles {

    /// Damped spring for tuner needle — nearly critically damped for precision feel.
    ///
    /// Parameters tuned for a precision instrument feel:
    /// - Duration: 0.4s (smooth response)
    /// - Bounce: 0.05 (near-critically damped, minimal overshoot)
    /// - Initial velocity: 0.0 (starts from rest)
    ///
    /// Use for: Tuner needle, gauge indicators, any precision instrument display.
    static let needle: Animation = .interpolatingSpring(
        duration: 0.4,
        bounce: 0.05,
        initialVelocity: 0.0
    )

    /// Slightly bouncier spring for UI interactions.
    ///
    /// Parameters tuned for tactile button feedback:
    /// - Duration: 0.25s (snappy response)
    /// - Bounce: 0.15 (subtle playful feel)
    /// - Initial velocity: 0.0 (starts from rest)
    ///
    /// Use for: String selection, button presses, tab switching, any user-initiated action.
    static let stringSelection: Animation = .interpolatingSpring(
        duration: 0.25,
        bounce: 0.15,
        initialVelocity: 0.0
    )

    /// Gentle breathing effect for in-tune state.
    ///
    /// Slow, smooth pulse that repeats forever with autoreverse.
    /// Creates a subtle "alive" feeling when the instrument is perfectly tuned.
    ///
    /// Use for: In-tune indicator glow, success state pulse, ambient feedback.
    static let inTunePulse: Animation = .easeInOut(duration: 1.5)
        .repeatForever(autoreverses: true)

    /// Standard UI transitions.
    ///
    /// Smooth, balanced animation for general UI state changes.
    /// Good default when no specific physics are required.
    ///
    /// Use for: View appearance/disappearance, opacity changes, general transitions.
    static let standard: Animation = .smooth(duration: 0.3)
}

// MARK: - Animation Helpers

extension AnimationStyles {

    /// Creates a damped spring with custom parameters.
    ///
    /// - Parameters:
    ///   - duration: The duration of the spring animation
    ///   - bounce: The bounce factor (0.0 = no bounce, 1.0 = maximum bounce)
    ///   - initialVelocity: The initial velocity of the animation
    /// - Returns: An interpolating spring animation
    static func spring(
        duration: Double,
        bounce: Double,
        initialVelocity: Double = 0.0
    ) -> Animation {
        .interpolatingSpring(
            duration: duration,
            bounce: bounce,
            initialVelocity: initialVelocity
        )
    }

    /// Creates a repeating pulse animation.
    ///
    /// - Parameters:
    ///   - duration: The duration of one pulse cycle
    ///   - autoreverse: Whether the animation should reverse (default: true)
    /// - Returns: A repeating ease-in-out animation
    static func pulse(duration: Double, autoreverse: Bool = true) -> Animation {
        .easeInOut(duration: duration)
            .repeatForever(autoreverses: autoreverse)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Animation Styles") {
    struct AnimationPreview: View {
        @State private var needlePosition: CGFloat = 0
        @State private var isSelected = false
        @State private var isInTune = false

        var body: some View {
            VStack(spacing: 40) {
                // Needle Animation Demo
                VStack {
                    Text("Needle (0.4s, 0.05 bounce)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                        .offset(x: needlePosition)
                        .animation(AnimationStyles.needle, value: needlePosition)
                }
                .frame(width: 200)

                // String Selection Demo
                VStack {
                    Text("String Selection (0.25s, 0.15 bounce)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.green : Color.gray)
                        .frame(width: isSelected ? 120 : 80, height: 40)
                        .animation(AnimationStyles.stringSelection, value: isSelected)
                }

                // In Tune Pulse Demo
                VStack {
                    Text("In Tune Pulse (1.5s repeat)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Circle()
                        .fill(Color.green)
                        .frame(width: isInTune ? 60 : 40, height: isInTune ? 60 : 40)
                        .opacity(isInTune ? 1.0 : 0.5)
                        .animation(isInTune ? AnimationStyles.inTunePulse : .default, value: isInTune)
                }

                // Controls
                HStack(spacing: 20) {
                    Button("Move Needle") {
                        needlePosition = needlePosition == 0 ? 80 : 0
                    }
                    .glassButton()

                    Button("Toggle Select") {
                        isSelected.toggle()
                    }
                    .glassButton()

                    Button("Toggle Pulse") {
                        isInTune.toggle()
                    }
                    .glassButton()
                }
            }
            .padding()
            .glassCard()
        }
    }

    return AnimationPreview()
}
#endif
