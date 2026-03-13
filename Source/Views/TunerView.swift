import SwiftUI

/// Main tuner view integrating all components with glass styling
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
                // Gauge section with top spacing
                TunerGaugeView(
                    cents: viewModel.cents,
                    isInTune: viewModel.isInTune
                )
                .padding(.top, 40)  // Gauge top to window: 40pt

                // Note display below gauge
                NoteDisplayView(
                    noteName: viewModel.noteNameText,
                    isInTune: viewModel.isInTune
                )
                .padding(.top, 16)  // Note display below gauge: 16pt

                // Cents readout below note
                CentsReadoutView(cents: viewModel.note != nil ? viewModel.cents : nil)
                .padding(.top, 8)  // Cents below note: 8pt

                // Reference pitch display
                ReferencePitchDisplay(referencePitch: viewModel.referencePitch)
                .padding(.top, 12)  // Reference pitch below cents: 12pt

                // Tuning selector (always visible - Phase 3 requirement)
                TuningSelector(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // String rail showing target notes for selected tuning
                StringRailView(viewModel: viewModel)
                    .padding(.horizontal)
                    // String rail spacing: 24pt above/below handled in StringRailView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)  // Outer padding from CONTEXT.md

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
