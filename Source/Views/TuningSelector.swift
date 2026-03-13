import SwiftUI

struct TuningSelector: View {
    @Bindable var viewModel: TunerViewModel
    @State private var showingCustomCreator = false

    var body: some View {
        VStack(spacing: 12) {
            // Instrument and Tuning pickers
            HStack(spacing: 12) {
                // Instrument picker
                InstrumentPicker(
                    selectedInstrument: $viewModel.selectedInstrument
                )

                // Tuning picker
                tuningPicker
            }

            // Create custom tuning button
            Button(action: { showingCustomCreator = true }) {
                Label("Create Custom Tuning", systemImage: "plus.circle")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primary)
        }
        .padding()
        .glassCard(cornerRadius: 16)
        .sheet(isPresented: $showingCustomCreator) {
            CustomTuningCreator(
                instrument: viewModel.selectedInstrument,
                onSave: { tuning in
                    Task {
                        try? await viewModel.saveCustomTuning(tuning)
                        showingCustomCreator = false
                    }
                },
                onCancel: {
                    showingCustomCreator = false
                }
            )
            .frame(minWidth: 400, minHeight: 500)
        }
    }

    private var tuningPicker: some View {
        Menu {
            tuningMenuContent
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "music.note.list")
                Text(viewModel.tuningLibrary.selectedTuning?.name ?? "Select Tuning")
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.secondary.opacity(0.1))
            .cornerRadius(8)
        }
        .menuStyle(.button)
    }

    @ViewBuilder
    private var tuningMenuContent: some View {
        // Group tunings by category
        let grouped = Dictionary(
            grouping: viewModel.tuningLibrary.availableTunings
        ) { $0.category }

        // Preset categories in order
        let orderedCategories: [TuningCategory] = [
            .standard, .drop, .open, .modal, .alternative
        ]

        // Show preset categories first
        ForEach(orderedCategories, id: \.self) { category in
            if let tunings = grouped[category], !tunings.isEmpty {
                Section(category.displayName) {
                    tuningMenuItems(tunings)
                }
            }
        }

        // Show custom tunings last
        if let customTunings = grouped[.custom], !customTunings.isEmpty {
            Section("Custom") {
                tuningMenuItems(customTunings)
            }
        }
    }

    private func tuningMenuItems(_ tunings: [Tuning]) -> some View {
        ForEach(tunings) { tuning in
            Button(action: {
                viewModel.selectTuning(tuning)
            }) {
                HStack {
                    if tuning.id == viewModel.tuningLibrary.selectedTuning?.id {
                        Image(systemName: "checkmark")
                    } else {
                        Image(systemName: "checkmark")
                            .opacity(0)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tuning.name)
                        Text(tuning.noteNames)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if tuning.isCustom {
                        Spacer()
                        Text("Custom")
                            .font(.caption2)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    TuningSelector(viewModel: TunerViewModel())
        .frame(width: 400)
        .padding()
}
