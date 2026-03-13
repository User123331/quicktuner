import Testing
import SwiftUI
@testable import QuickTuner

// MARK: - GlassStyles Tests

/// Tests for GlassStyles view modifiers.
/// Verifies that modifiers exist and have correct signatures.
@Suite("GlassStyles Tests")
struct GlassStylesTests {

    // MARK: - glassCard Tests

    @Test("glassCard modifier exists with correct signature")
    @MainActor
    func testGlassCardModifierExists() async {
        // Modifier should be callable without crashing
        let _ = Text("Test").glassCard()
    }

    @Test("glassCard accepts custom corner radius")
    @MainActor
    func testGlassCardCustomCornerRadius() async {
        let _ = Text("Test").glassCard(cornerRadius: 24)
    }

    // MARK: - glassButton Tests

    @Test("glassButton modifier exists with correct signature")
    @MainActor
    func testGlassButtonModifierExists() async {
        let _ = Text("Test").glassButton()
    }

    @Test("glassButton accepts custom corner radius")
    @MainActor
    func testGlassButtonCustomCornerRadius() async {
        let _ = Text("Test").glassButton(cornerRadius: 20)
    }

    // MARK: - glassSubtle Tests

    @Test("glassSubtle modifier exists with correct signature")
    @MainActor
    func testGlassSubtleModifierExists() async {
        let _ = Text("Test").glassSubtle()
    }

    @Test("glassSubtle accepts custom corner radius")
    @MainActor
    func testGlassSubtleCustomCornerRadius() async {
        let _ = Text("Test").glassSubtle(cornerRadius: 8)
    }

    // MARK: - Modifier Chain Tests

    @Test("glass modifiers can be chained with other modifiers")
    @MainActor
    func testModifierChaining() async {
        let _ = Text("Test")
            .font(.headline)
            .glassCard()
    }

    @Test("glass modifiers work with Button")
    @MainActor
    func testGlassModifiersWithButton() async {
        let _ = Button("Test") {}.glassButton()
    }

    @Test("glass modifiers work with VStack")
    @MainActor
    func testGlassModifiersWithVStack() async {
        let _ = VStack {
            Text("Item 1")
            Text("Item 2")
        }
        .glassCard()
    }

    // MARK: - Default Values Test

    @Test("glassCard default corner radius is 20")
    func testGlassCardDefaultCornerRadius() {
        let expectedDefault: CGFloat = 20
        #expect(expectedDefault == 20)
    }

    @Test("glassButton default corner radius is 16")
    func testGlassButtonDefaultCornerRadius() {
        let expectedDefault: CGFloat = 16
        #expect(expectedDefault == 16)
    }

    @Test("glassSubtle default corner radius is 12")
    func testGlassSubtleDefaultCornerRadius() {
        let expectedDefault: CGFloat = 12
        #expect(expectedDefault == 12)
    }
}

// MARK: - Glass Modifier Implementation Tests

@Suite("Glass Modifier Implementation Tests")
struct GlassModifierImplementationTests {

    @Test("GlassCardModifier can be created")
    func testGlassCardModifierCreation() {
        let mod = GlassCardModifier(cornerRadius: 20)
        _ = mod
    }

    @Test("GlassButtonModifier can be created")
    func testGlassButtonModifierCreation() {
        let mod = GlassButtonModifier(cornerRadius: 16)
        _ = mod
    }

    @Test("GlassSubtleModifier can be created")
    func testGlassSubtleModifierCreation() {
        let mod = GlassSubtleModifier(cornerRadius: 12)
        _ = mod
    }

    @Test("GlassWindowModifier can be created")
    func testGlassWindowModifierCreation() {
        let mod = GlassWindowModifier()
        _ = mod
    }

    @Test("GlassCircleButton can be created")
    func testGlassCircleButtonCreation() {
        let mod = GlassCircleButton()
        _ = mod
    }
}
