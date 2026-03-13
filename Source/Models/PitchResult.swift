import Foundation

struct PitchResult: Sendable {
    let frequency: Double
    let confidence: Double
    let timestamp: Date

    init(frequency: Double, confidence: Double, timestamp: Date = Date()) {
        self.frequency = frequency
        self.confidence = confidence
        self.timestamp = timestamp
    }
}
