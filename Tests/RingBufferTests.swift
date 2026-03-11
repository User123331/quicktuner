import XCTest
@testable import QuickTuner

final class RingBufferTests: XCTestCase {

    func testWriteAndRead() {
        let ringBuffer = RingBuffer(capacity: 1024)

        // Write some samples
        var input: [Float] = [1.0, 2.0, 3.0, 4.0, 5.0]
        input.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: input.count)
        }

        // Read them back
        var output = [Float](repeating: 0, count: 5)
        let count = ringBuffer.read(into: &output, count: 5)

        XCTAssertEqual(count, 5)
        XCTAssertEqual(output, [1.0, 2.0, 3.0, 4.0, 5.0])
    }

    func testCircularWrap() {
        let ringBuffer = RingBuffer(capacity: 10)

        // Write to near capacity
        var input1: [Float] = Array(repeating: 1.0, count: 8)
        input1.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: 8)
        }

        // Read 5
        var output1 = [Float](repeating: 0, count: 5)
        _ = ringBuffer.read(into: &output1, count: 5)

        // Write 5 more (should wrap)
        var input2: [Float] = [2.0, 2.0, 2.0, 2.0, 2.0]
        input2.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: 5)
        }

        // Read remaining
        var output2 = [Float](repeating: 0, count: 8)
        let count = ringBuffer.read(into: &output2, count: 8)

        XCTAssertEqual(count, 8)
        XCTAssertEqual(output2[0...2], [1.0, 1.0, 1.0])  // From first write
        XCTAssertEqual(output2[3...7], [2.0, 2.0, 2.0, 2.0, 2.0])  // From second write
    }

    func testAvailableSamples() {
        let ringBuffer = RingBuffer(capacity: 100)

        XCTAssertEqual(ringBuffer.availableSamples, 0)

        var input: [Float] = Array(repeating: 1.0, count: 50)
        input.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: 50)
        }

        XCTAssertEqual(ringBuffer.availableSamples, 50)

        var output = [Float](repeating: 0, count: 20)
        _ = ringBuffer.read(into: &output, count: 20)

        XCTAssertEqual(ringBuffer.availableSamples, 30)
    }

    func testReadMoreThanAvailable() {
        let ringBuffer = RingBuffer(capacity: 100)

        var input: [Float] = [1.0, 2.0, 3.0]
        input.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: 3)
        }

        // Try to read 10, should only get 3
        var output = [Float](repeating: 0, count: 10)
        let count = ringBuffer.read(into: &output, count: 10)

        XCTAssertEqual(count, 3)
        XCTAssertEqual(output[0...2], [1.0, 2.0, 3.0])
    }

    func testAsyncStreamYieldsWindows() async {
        let ringBuffer = RingBuffer(capacity: 4096)

        // Start the stream
        let stream = ringBuffer.analysisStream(windowSize: 512, overlap: 0.5)

        // Write enough data for one window
        var input: [Float] = Array(repeating: 0.5, count: 1024)
        input.withUnsafeBufferPointer { ptr in
            ringBuffer.write(ptr.baseAddress!, count: 1024)
        }

        // Collect one window
        var windows: [[Float]] = []
        for await window in stream {
            windows.append(window)
            if windows.count >= 1 { break }
        }

        XCTAssertEqual(windows.count, 1)
        XCTAssertEqual(windows[0].count, 512)
    }
}
