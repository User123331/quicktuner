---
phase: 02-tuner-interface
plan: 03
name: String Rail and Navigation
subsystem: View Layer
tags: [views, swiftui, navigation, keyboard]
requires: [02-02]
provides: [02-04, 02-05]
affects: [TunerView, StringRailView, StringPill]
tech-stack:
  added: [SwiftUI Button, onKeyPress modifier, SF Pro Rounded]
  patterns: [Binding, Keyboard Navigation, Focus Management]
key-files:
  created:
    - Sources/Views/StringPill.swift
    - Sources/Views/StringRailView.swift
    - Sources/Views/TunerView.swift
  modified: []
  deleted: []
decisions:
  - Horizontal pill layout for string rail matches standard tuner UX
  - Underline highlight provides clear visual indication of selected string
  - Click selection via Button with plain style for native interaction
  - Arrow keys for sequential navigation, number keys for direct access
  - Checkmark indicator for tuned strings per NAV-04
metrics:
  duration: 2 minutes
  completed: 2026-03-11
  tasks: 3
  files: 3
  tests: 60
  coverage: Existing test suite (TunerViewModel covers navigation)
---

# Phase 2 Plan 03: String Rail and Navigation Summary

## Overview

Built the string navigation rail with clickable pills and comprehensive keyboard support. This is the primary navigation mechanism enabling efficient string-by-string tuning via mouse, arrow keys, and direct number access.

**One-liner:** Horizontal string rail with 6 clickable pills featuring underline selection highlight, arrow/number keyboard navigation, and tuned state checkmarks.

## What Was Built

### StringPill (Sources/Views/StringPill.swift)

Individual string button component with visual states.

**Features:**

- **Note Display:** Note name + octave (e.g., "E2", "A2")
- **Selection State:** Bold weight + underline highlight when selected
- **Tuned State:** Green checkmark when string is tuned
- **Consistent Height:** Spacer maintains layout when checkmark hidden
- **Visual Feedback:** Subtle background fill and border when selected
- **SF Pro Rounded:** Modern rounded font appearance

**Key Parameters:**

```swift
let index: Int         // 0-based index
let noteName: String   // Note letter (E, A, D, G, B, etc.)
let octave: Int        // Octave number
let isSelected: Bool   // Underline + bold highlight
let isTuned: Bool      // Green checkmark indicator
let action: () -> Void // Selection handler
```

### StringRailView (Sources/Views/StringRailView.swift)

Container view managing the horizontal rail and keyboard navigation.

**Features:**

- **Horizontal Layout:** HStack with 8pt spacing between pills
- **Click Selection:** Button tap updates selected index
- **Arrow Navigation:**
  - Left arrow: previous string (decrement index)
  - Right arrow: next string (increment index)
  - Bounds checking prevents out-of-range selection
- **Number Navigation:** Keys 1-6 jump directly to strings
  - Converts 1-based display to 0-based internal index
- **Focus Management:** `.focusable()` enables keyboard events

**Key Parameters:**

```swift
@Binding var selectedIndex: Int  // Current selection (0-based)
let strings: [StringInfo]        // Array of string configurations
let tunedIndices: Set<Int>       // Set of tuned string indices
```

### TunerView (Sources/Views/TunerView.swift)

Integration view combining all tuner components.

**Layout:**

```
┌─────────────────────────────────────┐
│         NoteDisplayView             │  // Large note (E2, A2, etc.)
├─────────────────────────────────────┤
│        CentsReadoutView             │  // +5, -12, etc.
├─────────────────────────────────────┤
│         TunerGaugeView              │  // Canvas gauge
├─────────────────────────────────────┤
│   [E2] [A2] [D3] [G3] [B3] [E4]     │  // StringRailView
└─────────────────────────────────────┘
```

**Features:**

- Vertical stack with 24pt spacing between components
- Full frame sizing for flexible layout
- Lifecycle integration (start/stop audio)
- Keyboard focus at root level

## Interface Contracts

### Dependencies (from Phase 2-02)

| Component | Source | Usage |
|-----------|--------|-------|
| NoteDisplayView | Views/NoteDisplayView.swift | Large note name display |
| CentsReadoutView | Views/CentsReadoutView.swift | Cents deviation readout |
| TunerGaugeView | Views/TunerGaugeView.swift | Canvas-based pitch gauge |

### ViewModel Integration

| ViewModel Property | Usage |
|-------------------|-------|
| selectedStringIndex | Binding for rail selection |
| selectString(at:) | Programmatic selection |
| strings | Array of StringInfo for pills |
| tunedStrings | Set of tuned indices for checkmarks |
| noteNameText | Note name for display |
| cents | Pitch deviation for gauge/readout |
| isInTune | In-tune state for colors |

### Provided to Next Plans

| Component | Exports | Used By |
|-----------|---------|---------|
| StringRailView | Horizontal pill rail | TunerView |
| StringPill | Individual string button | StringRailView |
| TunerView | Full tuner integration | ContentView |

## Test Coverage

Tests from Phase 2-01 (TunerViewModelTests) cover navigation:

- `testDirectStringSelectionViaNumber` - Number key navigation
- `testStringSelectionBounds` - Arrow key bounds checking
- `testMarkStringAsTuned` - Tuned state tracking
- `testAllStringsTunedDetection` - Complete tuning state

All 60 existing tests pass with new components integrated.

## Deviations from Plan

**None** - Plan executed exactly as written.

All components match the specification:
- 6 string pills horizontally arranged
- Underline highlight when selected
- Click selection via Button
- Left/right arrow navigation
- Number keys 1-6 for direct access
- `.focusable()` for keyboard events
- Checkmarks for tuned strings

## Verification

- [x] `swift build` succeeds
- [x] StringRailView displays 6 string pills horizontally
- [x] StringPill shows underline when selected
- [x] Clicking pill updates selectedIndex
- [x] Left arrow decrements selectedIndex (bounds checked)
- [x] Right arrow increments selectedIndex (bounds checked)
- [x] Number keys 1-6 select corresponding string
- [x] Tuned strings show checkmark in pill
- [x] All 60 tests pass

## Key Decisions

1. **Button with .plain style:** Native SwiftUI Button provides accessibility and click handling without custom gestures.

2. **Underline highlight:** Horizontal line below note name provides clear visual indication without being distracting.

3. **Focus at rail level:** Keyboard modifiers attached to StringRailView for contained focus behavior.

4. **1-to-0 conversion:** Number keys 1-6 are converted to 0-based indices internally for array access.

5. **Consistent pill height:** Spacer maintains stable layout when checkmark appears/disappears.

## Dependencies for Next Plans

| Plan | Depends On This Output |
|------|------------------------|
| 02-04 All Tuned Badge | TunerView layout integration |
| 02-05 Complete Tuner | StringRailView positioning |

## Performance Notes

- Lightweight view structs with no @State
- Keyboard events handled natively by SwiftUI
- No animation overhead (reactive to ViewModel updates)
- SF Pro Rounded font uses system resources

## Commits

- `c9bada4` feat(phase-02-03): create StringPill component with underline highlight and checkmark support
- `9c9cf25` feat(phase-02-03): create StringRailView with keyboard navigation
- `6a4073e` feat(phase-02-03): create TunerView integrating all components

## Self-Check: PASSED

- [x] StringPill.swift exists and compiles
- [x] StringRailView.swift exists and compiles
- [x] TunerView.swift exists and compiles
- [x] All 60 tests pass
- [x] Build succeeds with no errors
- [x] Underline highlight on selected pill
- [x] Checkmark on tuned strings
- [x] Keyboard navigation implemented
