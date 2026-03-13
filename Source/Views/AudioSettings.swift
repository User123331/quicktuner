import SwiftUI

struct AudioSettings: View {
    @Bindable var viewModel: TunerViewModel

    var body: some View {
        Form {
            Section("Audio Device") {
                Picker(
                    "Input Device",
                    selection: Binding(
                        get: { viewModel.selectedDevice },
                        set: { device in
                            if let device {
                                Task { await viewModel.selectDevice(device) }
                            }
                        }
                    )
                ) {
                    Text("System Default").tag(AudioDevice?.none)
                    Divider()
                    ForEach(viewModel.availableDevices) { device in
                        Text(device.name).tag(AudioDevice?.some(device))
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Input Level") {
                InputLevelMeter(level: viewModel.levelMeterValue)
                    .padding(.vertical, 4)

                if viewModel.hasSignal {
                    Label("Signal detected", systemImage: "waveform")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Label("No signal", systemImage: "waveform.slash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Noise Gate") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Threshold")
                        Spacer()
                        Text("\(Int(viewModel.noiseGateThresholdDb)) dB")
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }

                    Slider(
                        value: Binding(
                            get: { Double(viewModel.noiseGateThresholdDb) },
                            set: { viewModel.setNoiseGateThreshold(Float($0)) }
                        ),
                        in: -80...(-20),
                        step: 1
                    )

                    Text("Audio below this level will be ignored. Lower values are more sensitive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await viewModel.refreshDevices()
        }
    }
}

#Preview {
    AudioSettings(viewModel: TunerViewModel())
        .frame(width: 400, height: 300)
}
