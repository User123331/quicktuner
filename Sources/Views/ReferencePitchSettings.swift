import SwiftUI

struct ReferencePitchSettings: View {
    @Bindable var viewModel: TunerViewModel

    private let minValue = ReferencePitchConstants.min
    private let maxValue = ReferencePitchConstants.max
    private let step = ReferencePitchConstants.step
    private let presets = ReferencePitchConstants.presets

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Reference Pitch")
                        .font(.headline)

                    Text("Sets the frequency of A4 (the A above middle C). Standard concert pitch is 440 Hz.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Numeric input with stepper
                    HStack(spacing: 12) {
                        Text("A4 =")
                            .font(.title3)

                        // Text field for direct entry
                        TextField(
                            "Hz",
                            value: $viewModel.referencePitch,
                            format: .number.precision(.fractionLength(1))
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .onChange(of: viewModel.referencePitch) { _, newValue in
                            viewModel.referencePitch = ReferencePitchConstants.normalize(newValue)
                        }

                        // Stepper buttons
                        Stepper(
                            value: $viewModel.referencePitch,
                            in: minValue...maxValue,
                            step: step
                        ) {
                            EmptyView()
                        }

                        Text("Hz")
                            .font(.title3)
                    }

                    // Preset buttons
                    HStack(spacing: 12) {
                        ForEach(presets, id: \.self) { preset in
                            Button(action: {
                                viewModel.referencePitch = preset
                            }) {
                                Text("\(Int(preset))")
                                    .fontWeight(isSelected(preset) ? .bold : .regular)
                                    .frame(minWidth: 60)
                            }
                            .buttonStyle(.bordered)
                            .tint(isSelected(preset) ? .accentColor : .secondary)
                        }
                    }

                    // Current selection indicator
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.primary)
                        Text("Current: A4 = \(viewModel.referencePitch, specifier: "%.1f") Hz")
                            .font(.subheadline)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }

            Section("About Reference Pitch") {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "440 Hz - Modern concert pitch (standard)",
                        systemImage: "checkmark"
                    )
                    Label(
                        "432 Hz - Alternative tuning community preference",
                        systemImage: "checkmark"
                    )
                    Label(
                        "420 Hz - Historical Baroque pitch",
                        systemImage: "checkmark"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func isSelected(_ preset: Double) -> Bool {
        abs(viewModel.referencePitch - preset) < 0.05
    }
}

#Preview {
    ReferencePitchSettings(viewModel: TunerViewModel())
        .frame(width: 400, height: 300)
}
