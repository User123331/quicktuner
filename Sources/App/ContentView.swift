import SwiftUI

/// Basic tuner view for Phase 1 testing
/// Shows pitch, note, cents, level meter, and device selection
struct ContentView: View {
    @State private var viewModel = TunerViewModel()
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 20) {
            // Header with settings button
            HStack {
                Text("QuickTuner")
                    .font(.largeTitle)

                Spacer()

                Button(action: { showingSettings = true }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(",", modifiers: .command)
                .help("Settings (⌘,)")
            }
            .padding(.horizontal)
            .padding(.top)

            // Main display
            VStack(spacing: 10) {
                // Note display
                Text(viewModel.noteNameText)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.hasSignal ? .primary : .secondary)

                // Frequency and cents
                HStack(spacing: 20) {
                    Text(viewModel.frequencyText)
                        .font(.system(.title2, design: .monospaced))

                    Text(viewModel.centsText)
                        .font(.system(.title2, design: .monospaced))
                        .foregroundStyle(centsColor)
                }

                // Reference pitch display (Phase 3-04)
                ReferencePitchDisplay(referencePitch: viewModel.referencePitch)
                    .padding(.top, 4)
            }
            .frame(height: 150)

            // Level meter (AUDIO-02)
            VStack(alignment: .leading, spacing: 5) {
                Text("Input Level")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))

                        // Level bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(levelBarColor)
                            .frame(width: geometry.size.width * CGFloat(viewModel.levelMeterValue))
                    }
                }
                .frame(height: 20)
            }
            .padding(.horizontal)

            // Confidence indicator
            HStack {
                Text("Confidence: \(Int(viewModel.confidence * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(viewModel.hasSignal ? "Signal" : "No Signal")
                    .font(.caption)
                    .foregroundStyle(viewModel.hasSignal ? .green : .orange)
            }
            .padding(.horizontal)

            // Device selection
            VStack(alignment: .leading, spacing: 5) {
                Text("Input Device")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Picker("Device", selection: Binding(
                    get: { viewModel.selectedDevice },
                    set: { device in
                        if let device = device {
                            Task {
                                await viewModel.selectDevice(device)
                            }
                        }
                    }
                )) {
                    ForEach(viewModel.availableDevices) { device in
                        Text(device.name).tag(device as AudioDevice?)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding(.horizontal)

            // Noise gate slider
            VStack(alignment: .leading, spacing: 5) {
                Text("Sensitivity: \(Int(viewModel.noiseGateThresholdDb)) dB")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Slider(
                    value: $viewModel.noiseGateThresholdDb,
                    in: Float(YINConfig.minNoiseGateDb)...Float(YINConfig.maxNoiseGateDb),
                    step: 1
                )
                .onChange(of: viewModel.noiseGateThresholdDb) { _, newValue in
                    viewModel.setNoiseGateThreshold(newValue)
                }
            }
            .padding(.horizontal)

            // Control button
            Button(action: {
                Task {
                    await viewModel.toggle()
                }
            }) {
                Label(
                    viewModel.isRunning ? "Stop" : "Start",
                    systemImage: viewModel.isRunning ? "stop.fill" : "mic.fill"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(minWidth: 400, minHeight: 500)
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
                .frame(minWidth: 500, minHeight: 400)
        }
        .task {
            await viewModel.refreshDevices()
            await viewModel.start()
        }
    }

    // MARK: - Helpers

    private var centsColor: Color {
        guard let note = viewModel.note else { return .secondary }
        if abs(note.cents) < 2 {
            return .green
        } else if abs(note.cents) < 10 {
            return .yellow
        } else {
            return .red
        }
    }

    private var levelBarColor: Color {
        if viewModel.levelMeterValue > 0.8 {
            return .red
        } else if viewModel.levelMeterValue > 0.5 {
            return .yellow
        } else {
            return .green
        }
    }
}

#Preview {
    ContentView()
}
