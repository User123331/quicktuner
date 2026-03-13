import SwiftUI

/// Root view for the QuickTuner app with Liquid Glass styling
/// Wraps the main TunerView in a glass-styled floating window
struct ContentView: View {
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Main content
            TunerView()
                .padding(.top, 52)        // Clear traffic light buttons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // Settings button overlay - positioned in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .modifier(GlassCircleButton())
                    }
                    .buttonStyle(.plain)
                    .focusEffectDisabled(true)
                    .padding(.top, 12)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .frame(width: 440, height: 600)
        .modifier(GlassWindowModifier())
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
