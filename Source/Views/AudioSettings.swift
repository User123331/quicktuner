import SwiftUI

struct AudioSettings: View {
    @AppStorage(PersistenceKeys.noiseGateThreshold)
    private var noiseGateThreshold: Double = -50.0

    var body: some View {
        Form {
            Section("Audio Device") {
                HStack {
                    Image(systemName: "mic")
                    Text("System Default")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Coming in Phase 4")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Noise Gate") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Threshold")
                        Spacer()
                        Text("\(Int(noiseGateThreshold)) dB")
                            .foregroundStyle(.secondary)
                            .font(.system(.body, design: .monospaced))
                    }

                    Slider(
                        value: $noiseGateThreshold,
                        in: -80...(-20),
                        step: 1
                    )

                    Text("Audio below this level will be ignored. Lower values are more sensitive.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Input Level") {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Input monitoring and device selection will be available in a future update.")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    AudioSettings()
        .frame(width: 400, height: 300)
}
