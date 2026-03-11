import SwiftUI
import Observation

@MainActor
@Observable
final class TuningLibrary {
    // MARK: - State
    var selectedInstrument: InstrumentType = .guitar6 {
        didSet {
            updateAvailableTunings()
        }
    }

    var selectedTuning: Tuning?
    var availableTunings: [Tuning] = []
    var customTunings: [Tuning] = []

    // MARK: - Initialization
    init() {
        loadPresets()
        updateAvailableTunings()
    }

    // MARK: - Public API

    func tunings(for instrument: InstrumentType) -> [Tuning] {
        let presets = presetTunings.filter { $0.instrument == instrument }
        let customs = customTunings.filter { $0.instrument == instrument }
        return presets + customs
    }

    func selectTuning(_ tuning: Tuning) {
        selectedTuning = tuning
    }

    func selectTuning(id: UUID) {
        selectedTuning = availableTunings.first { $0.id == id }
    }

    func addCustomTuning(_ tuning: Tuning) {
        guard tuning.isCustom else { return }
        customTunings.append(tuning)
        updateAvailableTunings()
    }

    func removeCustomTuning(id: UUID) {
        customTunings.removeAll { $0.id == id }
        updateAvailableTunings()
    }

    // MARK: - Private

    private func loadPresets() {
        // Presets are loaded from PresetTunings.swift
    }

    private func updateAvailableTunings() {
        availableTunings = tunings(for: selectedInstrument)

        // If current selection is not in new available list, select first
        if let current = selectedTuning,
           !availableTunings.contains(where: { $0.id == current.id }) {
            selectedTuning = availableTunings.first
        }

        // Default to first tuning if none selected
        if selectedTuning == nil {
            selectedTuning = availableTunings.first
        }
    }
}
