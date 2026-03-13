import SwiftUI

/// Root view for the QuickTuner app with Liquid Glass styling
/// Wraps the main TunerView in a glass-styled floating window
struct ContentView: View {
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Main content
            TunerView(onSettings: { showSettings = true })
                .padding(.top, 52)        // Clear traffic light buttons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .focusEffectDisabled(true)
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: createSettingsViewModel())
        }
    }

    /// Creates a standalone TunerViewModel for SettingsView
    /// This is separate from the one in TunerView to avoid conflicts
    private func createSettingsViewModel() -> TunerViewModel {
        TunerViewModel()
    }
}

// MARK: - Window Accessor

/// A helper to access the NSWindow and customize its properties.
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titlebarSeparatorStyle = .none
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Version-Gated Glass Modifiers

/// Glass effect for the main window container
struct GlassWindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: 24))
        } else {
            content
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
    }
}

/// Glass effect for circular buttons (e.g., settings gear)
struct GlassCircleButton: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
