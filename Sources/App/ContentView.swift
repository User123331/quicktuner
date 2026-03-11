import SwiftUI

/// Root view for the QuickTuner app with glass material background
/// Wraps the main TunerView in a glass-styled container
struct ContentView: View {
    var body: some View {
        ZStack {
            // Material background layer
            Color.clear
                .background(.thinMaterial)

            // Main content
            TunerView()
                .padding(24)  // Outer padding from CONTEXT.md
        }
        .frame(width: 440, height: 600)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
