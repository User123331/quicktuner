---
phase: 02-tuner-interface
plan: 02
name: Gauge Component
subsystem: View Layer
tags: [views, canvas, swiftui, gauge]
requires: [02-01]
provides: [02-03-string-rail, 02-04-note-display, 02-05-all-tuned-badge]
affects: [TunerView, TunerGaugeView, CentsReadoutView, NoteDisplayView]
tech-stack:
  added: [SwiftUI Canvas, SF Mono, SF Pro Rounded]
  patterns: [Canvas API, Custom Drawing, Monospaced Fonts]
key-files:
  created:
    - Sources/Views/TunerGaugeView.swift
    - Sources/Views/CentsReadoutView.swift
    - Sources/Views/NoteDisplayView.swift
    - Tests/TunerGaugeViewTests.swift
    - Tests/CentsReadoutViewTests.swift
    - Tests/NoteDisplayViewTests.swift
  modified: []
  deleted: []
decisions:
  - Canvas API chosen for Phase 4 Liquid Glass integration path
  - Semicircular arc from -90° to +90° for ±50 cent range
  - SF Mono for cents readout (numeric stability)
  - SF Pro Rounded for note display (modern appearance)
metrics:
  duration: 5 minutes
  completed: 2026-03-11
  tasks: 3
  files: 6
  tests: 41
  coverage: View initialization, rendering, color zones
---

# Phase 2 Plan 02: Gauge Component Summary

## Overview

Built the visual centerpiece of the tuner interface with three custom SwiftUI components. The Canvas-based gauge provides precise visual feedback on pitch deviation, with color-coded zones and smooth needle animation. Supporting components display the cents deviation and note name with appropriate typography.

**One-liner:** Canvas-based gauge with semicircular arc, color zones, needle indicator, and complementary cents/note readouts using SF Mono and SF Pro Rounded fonts.

## What Was Built

### TunerGaugeView (Sources/Views/TunerGaugeView.swift)

The main gauge component using SwiftUI Canvas for custom drawing.

**Features:**

- **Semicircular Arc:** Spans -90° to +90°, representing ±50 cents
- **Tick Marks:** At 0, ±10, ±25, ±50 cents positions
- **Color Zones:**
  - Green arc segment for ±2 cents (in-tune range)
  - Yellow tick markers at ±25 cents
  - Red needle color for deviations beyond ±25 cents
- **Needle:** Rotates based on cents value, colored by deviation
- **In-Tune Indicator:** Green stroke glow when `isInTune = true`
- **Center Pivot:** Visual dot at rotation center

**Key Parameters:**

```swift
let cents: Double        // -50 to +50 range
let isInTune: Bool       // Shows green indicator when true
```

### CentsReadoutView (Sources/Views/CentsReadoutView.swift)

Numeric display for cents deviation with color coding.

**Features:**

- Rounds to nearest integer (e.g., 15.7 → +16)
- Shows "--" when no pitch detected
- SF Mono font for numeric stability (monospaced digits)
- Color coding:
  - Green: ±2 cents
  - Yellow: ±3 to ±25 cents
  - Red: Beyond ±25 cents

### NoteDisplayView (Sources/Views/NoteDisplayView.swift)

Large note name display for current detected pitch.

**Features:**

- Large 72pt SF Pro Rounded font
- Shows "--" when no note detected
- Green color when in tune, primary color otherwise
- Smooth animation on in-tune state changes

## Interface Contracts

### Dependencies (from Phase 2-01)

| Component | Source | Usage |
|-----------|--------|-------|
| TunerViewModel.cents | ViewModels/TunerViewModel.swift | Needle position, readout value |
| TunerViewModel.isInTune | ViewModels/TunerViewModel.swift | Green indicator, color states |
| TunerViewModel.noteNameText | ViewModels/TunerViewModel.swift | Note display content |

### Provided to Next Plans

| Component | Exports | Used By |
|-----------|---------|---------|
| TunerGaugeView | Canvas gauge with needle | TunerView |
| CentsReadoutView | Integer cents with color | TunerView |
| NoteDisplayView | Large note name | TunerView |

## Test Coverage

### TunerGaugeView Tests (12 tests)

- Initialization with various cents values
- Range clamping at ±50 cents
- In-tune and out-of-tune states
- Color zone rendering (green, yellow, red)

### CentsReadoutView Tests (17 tests)

- Nil cents handling ("--")
- Rounding behavior (up, down, half)
- Sign display (+ for positive)
- Color coding at boundaries (±2, ±25)

### NoteDisplayView Tests (12 tests)

- Note name initialization
- Nil and empty handling
- In-tune color changes
- Various note formats (sharps, flats, octaves)

## Deviations from Plan

**None** - Plan executed exactly as written.

All three components match the specification:
- Canvas-based gauge with exact arc parameters
- SF Mono for cents readout
- SF Pro Rounded for note display
- Color zones at specified thresholds

## Verification

- [x] `swift build` succeeds
- [x] Canvas gauge draws semicircular arc from -90° to +90°
- [x] Tick marks appear at 0, ±10, ±25, ±50 cents
- [x] Color zones visible: green (±2¢), yellow markers (±25¢)
- [x] Needle rotates based on cents value (-50 to +50)
- [x] In-tune state shows green stroke on gauge rim
- [x] CentsReadoutView uses SF Mono font with color coding
- [x] NoteDisplayView uses SF Pro Rounded font

## Key Decisions

1. **Canvas API for gauge:** Chosen for maximum control over drawing and Phase 4 Liquid Glass integration path.

2. **Semicircular arc:** Bottom-half arc provides familiar tuner visual while leaving room for note display above.

3. **SF Mono for cents:** Monospaced digits prevent jitter when values change (equal character widths).

4. **SF Pro Rounded for notes:** Modern, friendly appearance matches Apple design language.

5. **Color thresholds:** Green ±2¢ matches in-tune threshold from TunerViewModel. Yellow ±25¢ provides clear transition zones.

## Dependencies for Next Plans

| Plan | Depends On This Output |
|------|------------------------|
| 02-03 String Rail | TunerGaugeView placement in layout |
| 02-04 Note Display | NoteDisplayView integration |
| 02-05 All Tuned Badge | CentsReadoutView positioning |

## Performance Notes

- Canvas drawing is GPU-accelerated on macOS
- No animation on needle (relies on EMA smoothing from ViewModel)
- Static text rendering via SwiftUI
- All components are lightweight structs (no @State)

## Commits

- `b19b4ee` feat(phase-02-02): create TunerGaugeView with Canvas-based rendering
- `ae9f8f1` feat(phase-02-02): create CentsReadoutView component
- `c73181b` feat(phase-02-02): create NoteDisplayView component

## Self-Check: PASSED

- [x] TunerGaugeView.swift exists and compiles
- [x] CentsReadoutView.swift exists and compiles
- [x] NoteDisplayView.swift exists and compiles
- [x] All test files exist
- [x] All 41 new tests pass
- [x] Full test suite passes (60 tests)
- [x] Canvas arc spans ±50 cents
- [x] Color zones at correct thresholds
- [x] SF Mono and SF Pro Rounded fonts used
