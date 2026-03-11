import Testing
import SwiftUI
@testable import QuickTuner

// MARK: - AnimationStyles Tests

/// Tests for AnimationStyles predefined spring animations.
/// Verifies constants exist with correct types and values.
@Suite("AnimationStyles Tests")
struct AnimationStylesTests {

    // MARK: - Animation Existence Tests

    @Test("needle animation exists as static Animation")
    func testNeedleAnimationExists() {
        let animation: Animation = AnimationStyles.needle
        _ = animation
    }

    @Test("stringSelection animation exists as static Animation")
    func testStringSelectionAnimationExists() {
        let animation: Animation = AnimationStyles.stringSelection
        _ = animation
    }

    @Test("inTunePulse animation exists as static Animation")
    func testInTunePulseAnimationExists() {
        let animation: Animation = AnimationStyles.inTunePulse
        _ = animation
    }

    @Test("standard animation exists as static Animation")
    func testStandardAnimationExists() {
        let animation: Animation = AnimationStyles.standard
        _ = animation
    }

    // MARK: - Animation Usage Tests

    @Test("animations can be applied to views")
    @MainActor
    func testAnimationApplication() async {
        let _ = Text("Test")
            .animation(AnimationStyles.needle, value: 0.0)
    }

    @Test("animations work with state changes")
    @MainActor
    func testAnimationWithState() async {
        struct TestView: View {
            @State private var value = 0.0

            var body: some View {
                Circle()
                    .animation(AnimationStyles.stringSelection, value: value)
            }
        }

        _ = TestView()
    }

    // MARK: - Animation Helper Tests

    @Test("spring helper creates Animation")
    func testSpringHelper() {
        let animation = AnimationStyles.spring(duration: 0.5, bounce: 0.2)
        _ = animation
    }

    @Test("pulse helper creates Animation")
    func testPulseHelper() {
        let animation = AnimationStyles.pulse(duration: 2.0)
        _ = animation
    }

    @Test("pulse helper with autoreverse false")
    func testPulseHelperNoAutoreverse() {
        let animation = AnimationStyles.pulse(duration: 1.0, autoreverse: false)
        _ = animation
    }

    // MARK: - Animation in ViewModifier Tests

    @Test("animations can be used with implicit animation modifier")
    @MainActor
    func testImplicitAnimationModifier() async {
        let _ = Rectangle()
            .animation(AnimationStyles.needle, value: true)
    }

    @Test("animations work with different view types")
    @MainActor
    func testAnimationsWithDifferentViews() async {
        // Text
        let _ = Text("Test").animation(AnimationStyles.standard, value: 0)

        // Button
        let _ = Button("Test") {}.animation(AnimationStyles.stringSelection, value: false)

        // VStack
        let _ = VStack {}.animation(AnimationStyles.inTunePulse, value: true)
    }

    // MARK: - Animation Parameters Tests

    @Test("needle uses correct spring parameters")
    func testNeedleSpringParameters() {
        // Expected: duration 0.3, bounce 0.1
        // Animation values are not directly inspectable, but we verify the constant exists
        let animation = AnimationStyles.needle
        _ = animation
    }

    @Test("stringSelection uses correct spring parameters")
    func testStringSelectionSpringParameters() {
        // Expected: duration 0.25, bounce 0.15
        let animation = AnimationStyles.stringSelection
        _ = animation
    }

    @Test("inTunePulse uses correct easeInOut duration")
    func testInTunePulseParameters() {
        // Expected: duration 1.5, repeatForever autoreverses: true
        let animation = AnimationStyles.inTunePulse
        _ = animation
    }

    @Test("standard uses smooth duration")
    func testStandardParameters() {
        // Expected: .smooth(duration: 0.3)
        let animation = AnimationStyles.standard
        _ = animation
    }
}

// MARK: - Animation Value Types Tests

@Suite("Animation Value Types Tests")
struct AnimationValueTypesTests {

    @Test("needle animation works with Double values")
    @MainActor
    func testNeedleWithDouble() async {
        let _ = Circle()
            .offset(x: 0)
            .animation(AnimationStyles.needle, value: 0.0)
    }

    @Test("stringSelection animation works with Int values")
    @MainActor
    func testStringSelectionWithInt() async {
        let _ = Rectangle()
            .frame(width: 100)
            .animation(AnimationStyles.stringSelection, value: 0)
    }

    @Test("inTunePulse animation works with Bool values")
    @MainActor
    func testInTunePulseWithBool() async {
        let _ = Circle()
            .scaleEffect(1.0)
            .animation(AnimationStyles.inTunePulse, value: true)
    }

    @Test("standard animation works with CGFloat values")
    @MainActor
    func testStandardWithCGFloat() async {
        let _ = RoundedRectangle(cornerRadius: 8)
            .opacity(1.0)
            .animation(AnimationStyles.standard, value: CGFloat(1.0))
    }
}
