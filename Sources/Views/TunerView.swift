import SwiftUI

/// Main tuner view integrating all components
/// Displays note, cents, gauge, tuning selector, string rail, and all-tuned badge with keyboard navigation
struct TunerView: View {
    @State private var viewModel: TunerViewModel

    init(viewModel: TunerViewModel = TunerViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
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
                .frame(maxHeight: .infinity)

                // Tuning selector (always visible - Phase 3 requirement)
                TuningSelector(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // String rail showing target notes for selected tuning
                StringRailView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
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
