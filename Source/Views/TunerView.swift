import SwiftUI

/// Main tuner view integrating all components with glass styling
/// Displays note, cents, gauge, tuning selector, string rail, and all-tuned badge with keyboard navigation
struct TunerView: View {
    @Bindable var viewModel: TunerViewModel
    var onSettings: (() -> Void)? = nil

    init(viewModel: TunerViewModel, onSettings: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSettings = onSettings
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
                .padding(.top, 8)  // ContentView already provides 52pt for traffic lights

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
                TuningSelector(viewModel: viewModel, onSettings: onSettings)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // String rail — Spacer pushes it to bottom, gap above separates it from TuningSelector
                Spacer(minLength: 0)
                StringRailView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
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
    TunerView(viewModel: TunerViewModel())
}
