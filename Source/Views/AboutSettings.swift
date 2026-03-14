import SwiftUI

struct AboutSettings: View {
    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "tuningfork")
                        .font(.system(size: 64))
                        .foregroundStyle(.primary)

                    Text("QuickTuner")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("A fast, accurate chromatic tuner for macOS")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }

            Section("Features") {
                VStack(alignment: .leading, spacing: 8) {
                    Label("36 preset tunings", systemImage: "guitars")
                    Label("Custom tuning creation", systemImage: "wand.and.stars")
                    Label("Adjustable reference pitch", systemImage: "tuningfork")
                    Label("Chromatic note detection", systemImage: "waveform")
                }
                .font(.body)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    AboutSettings()
        .frame(width: 400, height: 400)
}
