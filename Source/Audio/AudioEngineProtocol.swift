import Foundation

/// Protocol for audio engines that provide pitch detection streams
/// Used to allow both real AudioEngine and mock implementations in tests
protocol AudioEngineProtocol: Actor {
    /// AsyncStream of pitch detection results
    var pitchStream: AsyncStream<PitchResult> { get }
}

/// Extend AudioEngine to conform to AudioEngineProtocol
extension AudioEngine: AudioEngineProtocol {}
