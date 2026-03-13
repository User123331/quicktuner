---
phase: 07-gauge-and-meter-redesign
plan: "01"
subsystem: ui
tags: [swiftui, gauge, animation, trig, tdd]

# Dependency graph
requires:
  - phase: 06-audio-verification-and-ui-fixes
    provides: AnimationStyles.needle spring constants and in-tune detection pipeline
provides:
  - 240° speedometer-style TunerGaugeView with trig-based tick placement and numeric labels
  - NeedleShaft + CounterweightShape two-piece needle replacing broken triangle NeedleShape
  - arcAngle(for:) and tickPosition(cents:radius:) internal math functions
affects: [TunerView, future UI phases using TunerGaugeView]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "240° arc: trim(from: 0.167, to: 0.833) + .rotationEffect(.degrees(180)) for gap-at-bottom"
    - "Trig tick placement: sin/cos from arcAngle(for:) instead of offset+rotation(anchor:.center)"
    - "Two-shape needle: NeedleShaft(anchor:.bottom) + CounterweightShape(anchor:.top) share same rotationEffect"
    - "Internal access modifier on math functions enables @testable import in Swift Testing tests"

key-files:
  created: []
  modified:
    - Source/Views/TunerGaugeView.swift
    - Tests/TunerGaugeViewTests.swift

key-decisions:
  - "240° arc geometry: trim(from: 0.167, to: 0.833) maps to 240/360 = 0.667 fraction, rotated 180° so gap faces down"
  - "arcAngle(for:) uses ±120° range (not ±90°) for tick/label placement to fill the full 240° arc"
  - "angle(for:) kept semantically identical (±50¢ → ±90°) for needle - different range from arcAngle"
  - "Two-shape needle: NeedleShaft offset y:-(length/2) with anchor:.bottom + CounterweightShape offset y:+length/2 with anchor:.top — both rotate around ZStack center"
  - "Frame height increased 170→220pt to accommodate label clearance at arc endpoints"
  - "labelRadius = gaugeRadius + 18 (128pt) places labels just outside outer tick edge"

patterns-established:
  - "Trig-based arc element placement: CGPoint(x: R*sin(rad), y: -R*cos(rad)) relative to ZStack center"
  - "Path-based tick lines from inner to outer radius replace Rectangle+offset+rotationEffect pattern"

requirements-completed: [PITCH-02]

# Metrics
duration: 4min
completed: 2026-03-14
---

# Phase 7 Plan 01: Gauge and Meter Redesign Summary

**240° speedometer TunerGaugeView with trig-based ticks, numeric labels, and classic two-shape needle (NeedleShaft + CounterweightShape) replacing the broken 180° compass gauge**

## Performance

- **Duration:** 4 min
- **Started:** 2026-03-14T02:48:32Z
- **Completed:** 2026-03-14T02:52:29Z
- **Tasks:** 3 (TDD: RED test → GREEN implementation → verify)
- **Files modified:** 2

## Accomplishments
- Replaced broken 180° semicircle arc with correct 240° speedometer arc using `trim(from: 0.167, to: 0.833)` + 180° rotation
- Replaced scattered offset+rotation tick marks with trig-computed `tickPosition(cents:radius:)` using sin/cos from gauge pivot
- Replaced single NeedleShape triangle with two-shape needle: NeedleShaft (anchor:.bottom) + CounterweightShape (anchor:.top)
- Added numeric labels at -50, -25, 0, +25, +50 positions using `tickLabelsLayer`
- Added `arcAngle(for:)` (±50¢ → ±120°) and `tickPosition(cents:radius:)` as testable internal math functions
- All 20 TunerGaugeView tests pass (5 new tests added for new shapes and math functions)

## Task Commits

Each task was committed atomically:

1. **Task 1: Write tests for new shapes and math functions (RED)** - `27aca8c` (test)
2. **Task 2: Rewrite TunerGaugeView.swift** - `4e68642` (feat)
3. **Task 3: Verify tests go GREEN** - no commit needed (tests passed without changes)

## Files Created/Modified
- `Source/Views/TunerGaugeView.swift` - Complete rewrite: 240° arc, trig ticks, labels, NeedleShaft+CounterweightShape
- `Tests/TunerGaugeViewTests.swift` - Added testAngleMapping, testTickAngleMapping, testTickPositionCenter, testTickPositionRight, testCounterweightBounds; replaced NeedleShape tests with NeedleShaft tests

## Decisions Made
- **arcAngle uses ±120° range** — The 240° arc spans ±120° from vertical. Tick/label placement uses arcAngle(for:) (±120°) while the needle uses angle(for:) (±90°) — different ranges serve different purposes.
- **Two-shape needle geometry** — NeedleShaft positioned with `offset(y: -(needleLength/2))` centers it such that `anchor: .bottom` rotates around the ZStack center (gauge pivot). CounterweightShape positioned with `offset(y: counterweightLength/2)` such that `anchor: .top` also rotates around the same pivot.
- **Frame height 220pt** — Increased from 170pt to accommodate tick labels at arc endpoints (-50/+50 positions) without clipping.
- **Path-based ticks** — Used Path with move/addLine between inner and outer radius points (both computed via tickPosition) rather than Rectangle+offset for mathematically precise tick placement.

## Deviations from Plan

None - plan executed exactly as written. The `angle(for:)` function was `private` in the original source, requiring no change because the plan specified making it `internal` (no access modifier) — the implementation was done correctly in Task 2.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- TunerGaugeView is now a geometrically correct 240° speedometer instrument gauge
- TunerView.swift was not modified — public API (cents: Double, isInTune: Bool) is unchanged
- All 20 TunerGaugeView tests pass; full test suite passes
- Ready for visual UAT verification (run app and confirm gauge renders as speedometer shape)

---
*Phase: 07-gauge-and-meter-redesign*
*Completed: 2026-03-14*
