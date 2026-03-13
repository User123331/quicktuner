import SwiftUI

// MARK: - Glass Styles

/// Reusable view modifiers for Liquid Glass effects throughout the app.
///
/// On macOS 26+: Uses `.glassEffect()` with shape parameters for true Liquid Glass.
/// On older macOS: Falls back to `.background(.material)` for glass-like appearance.
///
/// ⚠️ WARNING: Never apply glass effects directly to Canvas views.
/// Glass effects on Canvas cause severe GPU overdraw (10-20fps instead of 60fps).
/// These modifiers are for CONTAINERS only.
///
/// ## Usage Examples
///
/// ```swift
/// // For containers and panels
/// VStack { ... }
///     .glassCard()
///
/// // For interactive buttons/pills
/// Button { ... }
///     .glassButton()
///
/// // For secondary elements or badges
/// Text("Badge")
///     .glassSubtle()
/// ```
extension View {

    /// Standard glass card style for containers.
    ///
    /// Uses `.glassEffect(.regular)` on macOS 26+ for true Liquid Glass.
    /// Falls back to `.thinMaterial` background on older macOS.
    ///
    /// - Parameter cornerRadius: The corner radius of the glass card (default: 20pt)
    /// - Returns: A view with the glass card effect applied
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    /// Glass button style for interactive elements.
    ///
    /// Uses `.glassEffect(.regular.interactive())` on macOS 26+ for interactive Liquid Glass.
    /// Falls back to `.ultraThinMaterial` background on older macOS.
    ///
    /// - Parameter cornerRadius: The corner radius of the button (default: 16pt)
    /// - Returns: A view with the glass button effect applied
    func glassButton(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassButtonModifier(cornerRadius: cornerRadius))
    }

    /// Subtle glass style for secondary elements.
    ///
    /// Uses `.glassEffect(.regular)` with lower prominence on macOS 26+.
    /// Falls back to `.ultraThinMaterial` background on older macOS.
    ///
    /// - Parameter cornerRadius: The corner radius of the element (default: 12pt)
    /// - Returns: A view with the subtle glass effect applied
    func glassSubtle(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassSubtleModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Glass Modifiers

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

struct GlassButtonModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

struct GlassSubtleModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
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
