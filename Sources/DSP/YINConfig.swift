import Foundation

enum YINConfig {
    // YIN algorithm parameters (locked from CONTEXT.md)
    static let minThreshold: Double = 0.10
    static let maxThreshold: Double = 0.15
    static let confidenceThreshold: Double = 0.5

    // Pitch detection range (guitar + bass)
    static let minFrequency: Double = 30.0   // Bass low B
    static let maxFrequency: Double = 1500.0 // High E + margin

    // Audio buffer specifications
    static let sampleRate: Double = 48000
    static let tapBufferSize: UInt32 = 1024
    static let analysisWindowSize = 4096
    static let ringBufferSize = 16384
    static let overlapRatio = 0.5

    // Noise gate range (user-configurable)
    static let defaultNoiseGateDb: Double = -40.0
    static let minNoiseGateDb: Double = -60.0
    static let maxNoiseGateDb: Double = -20.0
}
