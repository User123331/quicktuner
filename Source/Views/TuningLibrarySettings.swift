import SwiftUI

struct TuningLibrarySettings: View {
    @Bindable var viewModel: TunerViewModel

    var body: some View {
        Form {
            Section("Instrument") {
                Picker("Instrument", selection: $viewModel.selectedInstrument) {
                    ForEach(InstrumentType.allCases) { instrument in
                        Text(instrument.displayName)
                            .tag(instrument)
                    }
                }
                .pickerStyle(.menu)

                HStack {
                    Text("Strings:")
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.selectedInstrument.stringCount)")
                        .fontWeight(.medium)
                }
                .font(.caption)
            }

            Section("Current Tuning") {
                if let tuning = viewModel.tuningLibrary.selectedTuning {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tuning.name)
                                .font(.headline)
                            Text(tuning.category.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(tuning.noteNames)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("No tuning selected")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Available Tunings") {
                List(viewModel.tuningLibrary.availableTunings) { tuning in
                    TuningRow(
                        tuning: tuning,
                        isSelected: tuning.id == viewModel.tuningLibrary.selectedTuning?.id
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectTuning(tuning)
                    }
                }
                .frame(minHeight: 150)
            }

            Section("Custom Tunings") {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Create and manage custom tunings from the main tuning selector.")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct TuningRow: View {
    let tuning: Tuning
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .primary : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(tuning.name)
                    .font(.body)

                if tuning.isCustom {
                    Text("Custom")
                        .font(.caption2)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.primary.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            Spacer()

            Text(tuning.noteNames)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

#Preview {
    TuningLibrarySettings(viewModel: TunerViewModel())
        .frame(width: 400, height: 400)
}
