import SwiftUI

/// Main tuner view integrating all components
/// Displays note, cents, gauge, and string rail with keyboard navigation
struct TunerView: View {
    @State private var viewModel: TunerViewModel

    init(viewModel: TunerViewModel = TunerViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
