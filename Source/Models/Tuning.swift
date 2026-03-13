import Foundation

struct Tuning: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let instrument: InstrumentType
    let category: TuningCategory
    let notes: [TuningNote]  // Ordered: String 1 (high) to String N (low)
    let isCustom: Bool
    let isPreset: Bool

    init(
        id: UUID = UUID(),
        name: String,
        instrument: InstrumentType,
        category: TuningCategory,
        notes: [TuningNote],
        isCustom: Bool = false,
        isPreset: Bool = false
    ) {
        self.id = id
        self.name = name
        self.instrument = instrument
        self.category = category
        self.notes = notes
        self.isCustom = isCustom
        self.isPreset = isPreset
    }

    // Convenience computed property for display
    var noteNames: String {
        notes.map { "\($0.name)\($0.octave)" }.joined(separator: "-")
    }
}
