---
phase: 01-pitch-detection
plan: 03
subsystem: audio
completed: 2026-03-11
duration: 12m
commits: [01b0c5c, 598a4fe, a21f63c, 9be736c]
tech-stack:
  added: [AVFAudio, UnsafeMutablePointer]
  patterns: [Actor isolation, AsyncStream, Lock-free ring buffer, Three-layer threading]
key-decisions:
  - Use UnsafeMutablePointer.allocate for lock-free ring buffer (no ManagedBuffer needed for simple case)
  - Actor isolation for AudioEngine ensures thread-safe state management
  - AsyncStream bridges between real-time tap and background analysis
  - 50% overlap achieved by reading full window then skipping stepSize samples
  - Weak self in tap callback prevents retain cycle with ring buffer
key-files:
  created:
    - Sources/Audio/RingBuffer.swift
    - Sources/Audio/AudioEngine.swift
    - Sources/QuickTuner.entitlements
    - Sources/Info.plist
    - Tests/RingBufferTests.swift
  modified:
    - Package.swift (added AVFAudio linker setting)
---

# Phase 01 Plan 03: AudioEngine and RingBuffer Summary

**One-liner:** Lock-free RingBuffer and AudioEngine actor implementing three-layer threading architecture that safely bridges Core Audio real-time callbacks to Swift concurrency.

## What Was Built

### RingBuffer.swift (Sources/Audio/)

**Lock-Free Circular Buffer:**
- `UnsafeMutablePointer<Float>` for raw sample storage
- Single-producer (audio tap), single-consumer (analysis task)
- Write takes `UnsafePointer<Float>` - no allocations in real-time callback
- Read copies to Swift array for safe downstream use
- Capacity: 16384 samples (from YINConfig.ringBufferSize)

**Key Methods:**
- `write(_ samples: UnsafePointer<Float>, count: Int)` - Real-time safe write
- `read(into output: inout [Float], count: Int) -> Int` - Returns actual samples read
- `availableSamples: Int` - Samples ready for consumption
- `reset()` - Clear buffer for testing

**AsyncStream Extension:**
- `analysisStream(windowSize:overlap:)` yields overlapping windows
- Waits for sufficient samples via Task.sleep polling
- 50% overlap: yields every 2048 samples (~42.5ms effective rate)

### AudioEngine.swift (Sources/Audio/)

**Actor-Based Audio Management:**
- `actor AudioEngine` ensures thread-safe state isolation
- Manages AVAudioEngine lifecycle (start/stop)
- Owns RingBuffer instance

**Three-Layer Threading Architecture:**

```
Layer 1: Real-Time Audio Thread (tap callback)
  ↓ AVAudioEngine input tap
  ↓ ringBuffer.write() - NO allocations, NO locks, NO MainActor

Layer 2: Background Task (analysisLoop)
  ↓ Poll ringBuffer.availableSamples
  ↓ Read analysis window (4096 samples)
  ↓ PitchDetector.detect() - CPU intensive, off main thread
  ↓ Yield PitchResult via AsyncStream

Layer 3: MainActor (UI)
  ↓ Consume pitchStream
  ↓ Update @Published properties
  ↓ SwiftUI View renders
```

**Public Interface:**
- `start()` - Configure and start audio capture
- `stop()` - Clean shutdown with tap removal
- `pitchStream: AsyncStream<PitchResult>` - Pitch detection output
- `levelStream: AsyncStream<Float>` - Input level in dB for UI meter (AUDIO-02)
- `running: Bool` - Engine state

**Critical Implementation Details:**
- Tap callback uses `[weak self]` to prevent retain cycle
- Only `ringBuffer.write()` called from real-time thread
- Analysis loop polls at 0.5ms intervals until samples available
- Step size calculated from overlap ratio for proper window advancement

### Entitlements and Info.plist

**QuickTuner.entitlements:**
- `com.apple.security.app-sandbox` - Sandboxed macOS app
- `com.apple.security.device.audio-input` - Microphone access

**Info.plist:**
- `NSMicrophoneUsageDescription` - User-facing permission explanation
- Minimum macOS version: 15.0

These are REQUIRED for sandboxed release builds. Without them, microphone access fails silently.

### RingBufferTests.swift (Tests/)

**5 Unit Tests:**
| Test | Description |
|------|-------------|
| testWriteAndRead | Basic write then read back |
| testCircularWrap | Verify wrap-around when write index passes capacity |
| testAvailableSamples | Track available sample count |
| testReadMoreThanAvailable | Partial read returns actual count |
| testAsyncStreamYieldsWindows | AsyncStream produces analysis windows |

All tests pass: 5/5

## Verification Results

| Check | Status |
|-------|--------|
| Build | PASS |
| All 13 PitchDetectorTests | PASS |
| All 13 NoteClassifierTests | PASS |
| All 5 RingBufferTests | PASS |
| Swift 6 actor isolation | PASS (no warnings) |
| Entitlements configured | PASS |
| AVFAudio linked | PASS |

## Deviations from Plan

None - plan executed exactly as written.

## Integration Points

### Downstream Consumers (Wave 4)

| Component | Uses |
|-----------|------|
| AudioDeviceManager | Will integrate with AudioEngine for device selection |
| TunerViewModel | Consumes `pitchStream` and `levelStream` |
| Settings | Noise gate threshold passed to analysis loop |

### Requirements Satisfied

- PITCH-01: Real-time pitch detection pipeline complete
- AUDIO-02: Live input level meter via `levelStream`
- AUDIO-01: Foundation ready for device selection (Phase 1 wave 4)

## Self-Check

```bash
[ -f "Sources/Audio/RingBuffer.swift" ] && echo "FOUND: RingBuffer.swift" || echo "MISSING: RingBuffer.swift"
[ -f "Sources/Audio/AudioEngine.swift" ] && echo "FOUND: AudioEngine.swift" || echo "MISSING: AudioEngine.swift"
[ -f "Sources/QuickTuner.entitlements" ] && echo "FOUND: QuickTuner.entitlements" || echo "MISSING: QuickTuner.entitlements"
[ -f "Sources/Info.plist" ] && echo "FOUND: Info.plist" || echo "MISSING: Info.plist"
[ -f "Tests/RingBufferTests.swift" ] && echo "FOUND: RingBufferTests.swift" || echo "MISSING: RingBufferTests.swift"
git log --oneline --all | grep -q "01b0c5c" && echo "FOUND: commit 01b0c5c" || echo "MISSING: commit 01b0c5c"
git log --oneline --all | grep -q "598a4fe" && echo "FOUND: commit 598a4fe" || echo "MISSING: commit 598a4fe"
git log --oneline --all | grep -q "a21f63c" && echo "FOUND: commit a21f63c" || echo "MISSING: commit a21f63c"
git log --oneline --all | grep -q "9be736c" && echo "FOUND: commit 9be736c" || echo "MISSING: commit 9be736c"
```

**Self-Check: PASSED**

## Next Steps

Wave 4 (01-04) completes Phase 1:
- AudioDeviceManager for Core Audio device enumeration
- Device selection persistence via UserDefaults
- Hot-plug handling with fallback to default device
- Integration test with actual microphone input
