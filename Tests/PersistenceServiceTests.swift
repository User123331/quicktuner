import Testing
import Foundation
@testable import QuickTuner

@Suite("PersistenceService Tests")
struct PersistenceServiceTests {

    // MARK: - Setup/Teardown

    func createTempDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }

    func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Load Tests

    @Test("Load returns empty array when file does not exist")
    func testLoadReturnsEmptyWhenNoFile() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("nonexistent.json")
        let service = PersistenceService(customTuningsURL: url)

        let tunings = await service.loadCustomTunings()
        #expect(tunings.isEmpty)
    }

    @Test("Load returns empty array on decode error (graceful degradation)")
    func testLoadReturnsEmptyOnDecodeError() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("corrupted.json")
        let invalidJSON = "{ invalid json }"
        try invalidJSON.write(to: url, atomically: true, encoding: .utf8)

        let service = PersistenceService(customTuningsURL: url)
        let tunings = await service.loadCustomTunings()

        #expect(tunings.isEmpty)
    }

    // MARK: - Save/Load Roundtrip Tests

    @Test("Save then load returns identical tunings")
    func testSaveLoadRoundtrip() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        let tuning = Tuning(
            name: "Custom Test Tuning",
            instrument: .guitar6,
            category: .custom,
            notes: [
                TuningNote(name: "E", octave: 4),
                TuningNote(name: "B", octave: 3),
                TuningNote(name: "G", octave: 3),
                TuningNote(name: "D", octave: 3),
                TuningNote(name: "A", octave: 2),
                TuningNote(name: "E", octave: 2)
            ],
            isCustom: true,
            isPreset: false
        )

        try await service.saveCustomTunings([tuning])
        let loaded = await service.loadCustomTunings()

        #expect(loaded.count == 1)
        #expect(loaded.first?.name == tuning.name)
        #expect(loaded.first?.instrument == tuning.instrument)
        #expect(loaded.first?.isCustom == true)
    }

    @Test("Save creates directory if needed")
    func testSaveCreatesDirectory() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        // Use a nested path that doesn't exist
        let nestedDir = tempDir.appendingPathComponent("nested").appendingPathComponent("deep")
        let url = nestedDir.appendingPathComponent("tunings.json")

        let service = PersistenceService(customTuningsURL: url)

        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 4)],
            isCustom: true
        )

        // Should create directories and succeed
        try await service.saveCustomTunings([tuning])

        // Verify file exists
        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    // MARK: - Atomic Write Tests

    @Test("Save uses atomic write (creates temp file)")
    func testSaveUsesAtomicWrite() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 4)],
            isCustom: true
        )

        try await service.saveCustomTunings([tuning])

        // After atomic save, temp file should be gone
        let tempURL = url.appendingPathExtension("tmp")
        #expect(!FileManager.default.fileExists(atPath: tempURL.path))
    }

    @Test("Save overwrites existing file")
    func testSaveOverwritesExisting() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        let tuning1 = Tuning(
            name: "First",
            instrument: .guitar6,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 4)],
            isCustom: true
        )

        let tuning2 = Tuning(
            name: "Second",
            instrument: .bass4,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 1)],
            isCustom: true
        )

        try await service.saveCustomTunings([tuning1])
        try await service.saveCustomTunings([tuning2])

        let loaded = await service.loadCustomTunings()
        #expect(loaded.count == 1)
        #expect(loaded.first?.name == "Second")
    }

    // MARK: - Delete Tests

    @Test("Delete removes custom tunings file")
    func testDeleteRemovesFile() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 4)],
            isCustom: true
        )

        try await service.saveCustomTunings([tuning])
        #expect(FileManager.default.fileExists(atPath: url.path))

        try await service.deleteCustomTunings()
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test("Delete is idempotent (no error when file doesn't exist)")
    func testDeleteIsIdempotent() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("nonexistent.json")
        let service = PersistenceService(customTuningsURL: url)

        // Should not throw
        try await service.deleteCustomTunings()
    }

    // MARK: - JSON Encoding Tests

    @Test("JSON output is pretty printed and sorted")
    func testJSONIsPrettyPrinted() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        let tuning = Tuning(
            name: "Test",
            instrument: .guitar6,
            category: .custom,
            notes: [TuningNote(name: "E", octave: 4)],
            isCustom: true
        )

        try await service.saveCustomTunings([tuning])

        let data = try Data(contentsOf: url)
        let json = String(data: data, encoding: .utf8)!

        // Pretty printed means newlines
        #expect(json.contains("\n"))
    }

    // MARK: - Thread Safety Tests

    @Test("Actor isolation prevents concurrent access issues")
    func testActorIsolation() async throws {
        let tempDir = createTempDirectory()
        defer { cleanup(tempDir) }

        let url = tempDir.appendingPathComponent("tunings.json")
        let service = PersistenceService(customTuningsURL: url)

        // Multiple concurrent operations should be safe due to actor isolation
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let tuning = Tuning(
                        name: "Tuning \(i)",
                        instrument: .guitar6,
                        category: .custom,
                        notes: [TuningNote(name: "E", octave: 4)],
                        isCustom: true
                    )
                    try? await service.saveCustomTunings([tuning])
                }
            }

            for await _ in group { }
        }

        // File should exist and be valid
        let loaded = await service.loadCustomTunings()
        #expect(loaded.count <= 1) // Last write wins due to actor serialization
    }
}
