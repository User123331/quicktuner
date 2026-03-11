import Foundation
@testable import QuickTuner

/// Mock AudioEngine for testing that allows manual pitch result injection
actor MockAudioEngine: AudioEngineProtocol {
    private var _pitchStream: AsyncStream<PitchResult>?
    private var _pitchContinuation: AsyncStream<PitchResult>.Continuation?

    var pitchStream: AsyncStream<PitchResult> {
        if let stream = _pitchStream {
            return stream
        }
        let stream = AsyncStream<PitchResult> { continuation in
            self._pitchContinuation = continuation
        }
        _pitchStream = stream
        return stream
    }

    func yieldPitchResult(_ result: PitchResult) {
        _pitchContinuation?.yield(result)
    }

    func finishStream() {
        _pitchContinuation?.finish()
    }
}
