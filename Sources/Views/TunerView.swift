import SwiftUI

/// Main tuner view integrating all components
/// Displays note, cents, gauge, string rail, and all-tuned badge with keyboard navigation
struct TunerView: View {
    @State private var viewModel: TunerViewModel

    init(viewModel: TunerViewModel = TunerViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 24) {
                // Note display
                NoteDisplayView(
                    noteName: viewModel.noteNameText,
                    isInTune: viewModel.isInTune
                )

                // Cents readout
                CentsReadoutView(cents: viewModel.note != nil ? viewModel.cents : nil)

                // Gauge
                TunerGaugeView(
                    cents: viewModel.cents,
                    isInTune: viewModel.isInTune
                )

                // String rail
                StringRailView(
                    selectedIndex: Binding(
                        get: { viewModel.selectedStringIndex },
                        set: { viewModel.selectString(at: $0) }
                    ),
                    strings: viewModel.strings,
                    tunedIndices: viewModel.tunedStrings
                )

                // Reset button with keyboard shortcut
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.resetTunedStrings()
                    }) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut("r", modifiers: .command)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)

            // All Tuned badge overlay
            if viewModel.showAllTunedBadge {
                AllTunedBadgeView {
                    viewModel.dismissAllTunedBadge()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .focusable()
        .task {
            await viewModel.start()
        }
        .onDisappear {
            Task {
                await viewModel.stop()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TunerView()
}
