import SwiftUI

/// Root view for the QuickTuner app with glass material background
/// Wraps the main TunerView in a glass-styled container
struct ContentView: View {
    @State private var showSettings = false

    var body: some View {
        ZStack {
            // Material background layer
            Color.clear
                .background(.thinMaterial)
                .ignoresSafeArea()

            // Main content
            TunerView()
                .padding(24)  // Outer padding from CONTEXT.md

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
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .focusEffectDisabled(true)
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .frame(width: 440, height: 600)
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

// MARK: - Preview
#Preview {
    ContentView()
}
