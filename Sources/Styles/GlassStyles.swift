import SwiftUI

// MARK: - Glass Styles

/// Reusable view modifiers for glass-like effects throughout the app.
///
/// These modifiers provide consistent glass styling for containers, buttons,
/// and secondary elements using material backgrounds and corner radii.
///
/// ## macOS Version Compatibility
///
/// On macOS 15: Uses `.thinMaterial` and `.ultraThinMaterial` backgrounds
///               with corner radii for a glass-like appearance.
/// On macOS 26+: Automatically applies `.glassEffect()` for true Liquid Glass.
///
/// ⚠️ WARNING: Never apply glass effects directly to Canvas views.
/// Glass effects on Canvas cause severe GPU overdraw (10-20fps instead of 60fps).
/// These modifiers are for CONTAINERS only.
///
/// ## Usage Examples
///
/// ```swift
/// // For gauge container or settings panels
/// TunerGaugeView()
///     .glassCard()
///
/// // For string pills or control buttons
/// StringPill()
///     .glassButton()
///
/// // For secondary elements or badges
/// StatusBadge()
///     .glassSubtle()
/// ```
extension View {

    /// Standard glass card style for containers.
    ///
    /// Uses `.thinMaterial` for a balanced glass appearance.
    /// Ideal for gauge containers, settings panels, and primary content areas.
    ///
    /// Modifier order: background -> cornerRadius -> glassEffect (macOS 26+)
    ///
    /// - Parameter cornerRadius: The corner radius of the glass card (default: 20pt)
    /// - Returns: A view with the glass card effect applied
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.thinMaterial)
            .cornerRadius(cornerRadius)
            .modifier(GlassEffectModifier(style: .standard))
    }

    /// Glass button style for interactive elements.
    ///
    /// Uses `.ultraThinMaterial` for more transparency on buttons.
    /// Ideal for string pills, control buttons, and interactive cards.
    ///
    /// Modifier order: background -> cornerRadius -> glassEffect (macOS 26+)
    ///
    /// - Parameter cornerRadius: The corner radius of the button (default: 16pt)
    /// - Returns: A view with the glass button effect applied
    func glassButton(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .modifier(GlassEffectModifier(style: .interactive))
    }

    /// Subtle glass style for secondary elements.
    ///
    /// Uses `.ultraThinMaterial` for minimal visual weight.
    /// Ideal for badges, status indicators, and background elements.
    ///
    /// Modifier order: background -> cornerRadius -> glassEffect (macOS 26+)
    ///
    /// - Parameter cornerRadius: The corner radius of the element (default: 12pt)
    /// - Returns: A view with the subtle glass effect applied
    func glassSubtle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .modifier(GlassEffectModifier(style: .clear))
    }
}

// MARK: - Glass Effect Modifier

/// Glass effect style variants.
enum GlassEffectStyle {
    case standard
    case interactive
    case clear
}

/// View modifier that applies glass effects conditionally based on OS version.
struct GlassEffectModifier: ViewModifier {
    let style: GlassEffectStyle

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.modifier(GlassEffectModifier26(style: style))
        } else {
            // On macOS 15, the material background already provides glass-like appearance
            content
        }
    }
}

/// macOS 26+ specific implementation of glass effect.
@available(macOS 26.0, *)
struct GlassEffectModifier26: ViewModifier {
    let style: GlassEffectStyle

    func body(content: Content) -> some View {
        switch style {
        case .standard:
            content.glassEffect()
        case .interactive:
            content.glassEffect(.clear.interactive())
        case .clear:
            content.glassEffect(.clear)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Glass Styles") {
    VStack(spacing: 24) {
        // Glass Card
        VStack {
            Text("Glass Card")
                .font(.headline)
            Text("For containers, panels, gauges")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 200, height: 100)
        .glassCard()

        // Glass Button
        Button("Glass Button") {}
            .frame(width: 150, height: 44)
            .glassButton()

        // Glass Subtle
        Text("Subtle Badge")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassSubtle()
    }
    .padding()
    .background(
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
#endif
