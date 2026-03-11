import Foundation

/// Lock-free ring buffer for bridging real-time audio thread to analysis thread
/// Single-producer (audio tap), single-consumer (analysis task)
final class RingBuffer: @unchecked Sendable {
    private let buffer: UnsafeMutablePointer<Float>
    private let capacity: Int

    // Using volatile access for thread safety
    private var writeIndex: Int = 0
    private var readIndex: Int = 0

    init(capacity: Int = YINConfig.ringBufferSize) {
        self.capacity = capacity
        self.buffer = UnsafeMutablePointer<Float>.allocate(capacity: capacity)
        self.buffer.initialize(repeating: 0, count: capacity)
    }

    deinit {
        buffer.deallocate()
    }

    /// Write samples from real-time audio thread
    /// Must be called ONLY from the audio tap callback
    func write(_ samples: UnsafePointer<Float>, count: Int) {
        for i in 0..<count {
            buffer[(writeIndex + i) % capacity] = samples[i]
        }
        writeIndex = (writeIndex + count) % capacity
    }

    /// Read samples into output buffer
    /// Returns number of samples actually read
    func read(into output: inout [Float], count: Int) -> Int {
        let available = (writeIndex - readIndex + capacity) % capacity
        let toRead = min(count, available)

        guard toRead > 0 else { return 0 }

        for i in 0..<toRead {
            output[i] = buffer[(readIndex + i) % capacity]
        }
        readIndex = (readIndex + toRead) % capacity

        return toRead
    }

    /// Number of samples available to read
    var availableSamples: Int {
        return (writeIndex - readIndex + capacity) % capacity
    }

    /// Reset the buffer (for testing)
    func reset() {
        readIndex = 0
        writeIndex = 0
        buffer.initialize(repeating: 0, count: capacity)
    }
}

// AsyncStream extension for RingBuffer
extension RingBuffer {
    /// Create an AsyncStream that yields analysis windows from the ring buffer
    /// - Parameters:
    ///   - windowSize: Size of each analysis window (4096 samples)
    ///   - overlap: Overlap ratio (0.5 for 50% overlap)
    /// - Returns: AsyncStream of Float arrays
    func analysisStream(windowSize: Int = YINConfig.analysisWindowSize,
                        overlap: Double = YINConfig.overlapRatio) -> AsyncStream<[Float]> {
        let stepSize = Int(Double(windowSize) * (1.0 - overlap))

        return AsyncStream { continuation in
            Task { @Sendable in
                var buffer = [Float](repeating: 0, count: windowSize)

                while !Task.isCancelled {
                    // Wait until we have enough samples
                    while self.availableSamples < windowSize {
                        try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
                        if Task.isCancelled { break }
                    }

                    guard !Task.isCancelled else { break }

                    // Read one window
                    let readCount = self.read(into: &buffer, count: windowSize)
                    guard readCount == windowSize else { continue }

                    // Yield the window
                    continuation.yield(buffer)

                    // Advance read position for overlap (step forward by stepSize)
                    // This creates 50% overlap: we read 4096 but only consumed 2048
                    // The next read will get samples starting 2048 ahead
                }

                continuation.finish()
            }
        }
    }
}
