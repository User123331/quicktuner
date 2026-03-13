import Foundation

// MARK: - Persistence Keys
/// UserDefaults keys for @AppStorage and persistence
enum PersistenceKeys {
    static let selectedInstrument = "selectedInstrument"
    static let selectedTuningId = "selectedTuningId"
    static let referencePitch = "referencePitch"
    static let noiseGateThreshold = "noiseGateThreshold"
    static let selectedAudioDeviceId = "selectedAudioDeviceId"
}

// MARK: - Reference Pitch Constants
/// Constants for reference pitch (A4 frequency) configuration
enum ReferencePitchConstants {
    static let min: Double = 420.0
    static let max: Double = 444.0
    static let `default`: Double = 440.0
    static let step: Double = 0.1
    static let presets: [Double] = [440.0, 432.0, 420.0]

    /// Clamps and rounds value to valid reference pitch
    /// - Parameter value: The raw reference pitch value
    /// - Returns: A normalized value clamped between min/max and rounded to 1 decimal place
    static func normalize(_ value: Double) -> Double {
        let clamped = Swift.max(min, Swift.min(max, value))
        return round(clamped * 10) / 10  // 1 decimal place
    }
}

// MARK: - File Paths
/// File path helpers for Application Support directory
enum FilePaths {
    /// The Application Support directory URL for the current user
    static var applicationSupportDirectory: URL {
        FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
    }

    /// The QuickTuner subdirectory in Application Support
    static var quickTunerDirectory: URL {
        applicationSupportDirectory.appendingPathComponent("QuickTuner")
    }

    /// The URL for the custom tunings JSON file
    static var customTuningsURL: URL {
        quickTunerDirectory.appendingPathComponent("custom-tunings.json")
    }
}
