import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: TunerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        TabView {
            ReferencePitchSettings(viewModel: viewModel)
                .tabItem {
                    Label("Reference Pitch", systemImage: "tuningfork")
                }
                .tag(SettingsTab.referencePitch)

            TuningLibrarySettings(viewModel: viewModel)
                .tabItem {
                    Label("Tuning Library", systemImage: "guitars")
                }
                .tag(SettingsTab.tuningLibrary)

            AudioSettings()
                .tabItem {
                    Label("Audio", systemImage: "mic")
                }
                .tag(SettingsTab.audio)

            AboutSettings()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(SettingsTab.about)
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
        }
    }
}

enum SettingsTab: String, CaseIterable {
    case referencePitch
    case tuningLibrary
    case audio
    case about
}

#Preview {
    SettingsView(viewModel: TunerViewModel())
}
