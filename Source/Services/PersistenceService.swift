import Foundation

/// Actor-based persistence service for thread-safe file operations
/// Handles custom tuning persistence with atomic writes to prevent corruption
actor PersistenceService {
    static let shared = PersistenceService()

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let customTuningsURL: URL

    /// Initialize with custom URL (for testing) or default Application Support location
    /// - Parameter customTuningsURL: URL for custom tunings JSON file
    init(customTuningsURL: URL = FilePaths.customTuningsURL) {
        self.customTuningsURL = customTuningsURL

        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Custom Tunings

    /// Load custom tunings from JSON file
    /// - Returns: Array of Tuning structs, or empty array if file doesn't exist or is corrupted
    func loadCustomTunings() async -> [Tuning] {
        guard FileManager.default.fileExists(atPath: customTuningsURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: customTuningsURL)
            return try decoder.decode([Tuning].self, from: data)
        } catch {
            print("Failed to load custom tunings: \(error)")
            // Graceful degradation: return empty array on error
            return []
        }
    }

    /// Save custom tunings to JSON file using atomic write
    /// - Parameter tunings: Array of Tuning structs to save
    /// - Throws: PersistenceError on encoding or file write failures
    func saveCustomTunings(_ tunings: [Tuning]) async throws {
        // Create directory if needed
        let directory = customTuningsURL.deletingLastPathComponent()
        try createDirectoryIfNeeded(at: directory)

        // Encode data
        let data = try encoder.encode(tunings)

        // Atomic write: write to temp, then move
        // Per RESEARCH.md Pitfall 3: prevents corruption on crash
        let tempURL = customTuningsURL.appendingPathExtension("tmp")
        try data.write(to: tempURL, options: .atomic)

        // Remove existing file if present (moveItem fails if destination exists)
        if FileManager.default.fileExists(atPath: customTuningsURL.path) {
            try FileManager.default.removeItem(at: customTuningsURL)
        }

        try FileManager.default.moveItem(at: tempURL, to: customTuningsURL)
    }

    /// Delete custom tunings file
    /// - Throws: PersistenceError on file removal failures
    func deleteCustomTunings() async throws {
        guard FileManager.default.fileExists(atPath: customTuningsURL.path) else {
            return
        }
        try FileManager.default.removeItem(at: customTuningsURL)
    }

    // MARK: - Private Helpers

    private func createDirectoryIfNeeded(at url: URL) throws {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(
            atPath: url.path,
            isDirectory: &isDirectory
        )

        if !exists {
            // Per RESEARCH.md Pitfall 7: create directory before writing
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
}

// MARK: - Persistence Errors

enum PersistenceError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case fileWriteFailed(Error)
    case directoryCreationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .fileWriteFailed(let error):
            return "Failed to write file: \(error.localizedDescription)"
        case .directoryCreationFailed(let error):
            return "Failed to create directory: \(error.localizedDescription)"
        }
    }
}
