---
phase: 09-window-compactness-settings-polish
plan: 03
subsystem: UI
tags: [input-meter, dynamic-width, geometry-reader, vu-meter]
duration: 15 minutes
completed: 2026-03-14
requires:
  - AUDIO-02
provides:
  - Dynamic-width Input Level meter
  - Responsive VU meter scaling
affects:
  - AudioSettings view
  - Settings panel layout
tech-stack:
  added:
    - SwiftUI GeometryReader for dynamic width
    - Computed segment count based on available width
  patterns:
    - 90% container width fill
    - 60/25/15% color zone ratio calculation
    - Min/max segment bounds (10-40)
key-files:
  created:
    - Tests/InputLevelMeterTests.swift
  modified:
    - Source/Views/InputLevelMeter.swift
decisions:
  - Use GeometryReader to get container width dynamically
  - Target 90% of container width for meter fill
  - Calculate segment count from available space with 8pt minimum segment width
  - Cap segments at 40 maximum to prevent tiny bars
  - Maintain 60/25/15% color zone ratio regardless of segment count
---

# Phase 09 Plan 03: Dynamic-Width Input Level Meter Summary

## One-Liner

Replaced fixed 200pt Input Level meter with dynamic implementation using GeometryReader to fill 90% of container width with segment count scaling based on available space.

## What Changed

### Files Modified

1. **Source/Views/InputLevelMeter.swift** - Complete rewrite with GeometryReader
   - Added GeometryReader wrapper to access container dimensions
   - Added `calculateSegmentCount(for:)` method computing segments from available width
   - Added `calculateSegmentWidth(totalWidth:segmentCount:)` for dynamic segment sizing
   - Changed color zone counts from fixed constants to computed values (60/25/15%)
   - Added `minSegmentWidth = 8pt` and `maxSegments = 40` constraints
   - Added `.position()` for centering in GeometryReader

2. **Tests/InputLevelMeterTests.swift** - New test file
   - Initialization tests for zero, mid, and full level
   - Color zone ratio verification tests (60/25/15%)
   - Segment width calculation tests
   - Segment count scaling tests

### Key Implementation Details

**Dynamic Width Calculation:**
```swift
let targetWidth = geometry.size.width * 0.9  // 90% of container
let segmentCount = calculateSegmentCount(for: targetWidth)
let segmentWidth = calculateSegmentWidth(totalWidth: targetWidth, segmentCount: segmentCount)
```

**Segment Count Formula:**
```swift
private func calculateSegmentCount(for width: CGFloat) -> Int {
    let maxPossible = Int((width + segmentSpacing) / (minSegmentWidth + segmentSpacing))
    return min(max(maxPossible, 10), maxSegments)  // Min 10, max 40
}
```

**Color Zone Ratios (Dynamic):**
```swift
let greenCount = Int(Float(segmentCount) * 0.6)   // 60% green
let yellowCount = Int(Float(segmentCount) * 0.25)  // 25% yellow
// Remaining 15% red
```

## Deviations from Plan

None - plan executed exactly as written.

## Verification

- [x] Tests pass: `swift test --filter InputLevelMeterTests`
- [x] InputLevelMeter.swift contains GeometryReader
- [x] Segment count is calculated dynamically
- [x] Color zones use 60/25/15% ratio calculation
- [x] Checkpoint verified by user (approved)

## Commits

| Commit | Message |
|--------|---------|
| c195c7f | test(09-03): add tests for InputLevelMeter dynamic width |
| 8905f56 | feat(09-03): implement dynamic-width InputLevelMeter |

## Self-Check: PASSED

- Files exist: Source/Views/InputLevelMeter.swift, Tests/InputLevelMeterTests.swift
- Commits verified in git log
- Tests passing