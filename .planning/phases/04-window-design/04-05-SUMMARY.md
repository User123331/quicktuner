---
phase: 04-window-design
plan: 05
subsystem: Colors and Typography
 tags: [swiftui, colors, typography, assets, dark-mode]
requires:
  - 04-04
provides:
  - UI-03
  - UI-05
affects: [TunerGaugeView, CentsReadoutView, NoteDisplayView, StringRailView, ReferencePitchDisplay, appearance]
tech-stack:
  added:
    - Colors.xcassets with semantic color definitions
    - SF Pro Rounded font (system)
    - SF Mono font (system)
  patterns:
    - Asset catalog color definitions with luminosity variants
    - Semantic color usage (InTuneGreen, WarningOrange, ErrorRed)
    - System font with design parameter for typography
key-files:
  created:
    - Resources/Colors.xcassets/InTuneGreen.colorset/Contents.json
    - Resources/Colors.xcassets/WarningOrange.colorset/Contents.json
    - Resources/Colors.xcassets/ErrorRed.colorset/Contents.json
  modified:
    - Sources/Views/TunerGaugeView.swift
    - Sources/Views/CentsReadoutView.swift
    - Sources/Views/NoteDisplayView.swift
    - Sources/Views/StringRailView.swift
    - Sources/Views/ReferencePitchDisplay.swift
decisions:
  - "Color thresholds: <5¢ green, <20¢ orange, >=20¢ red (tighter than previous <=2¢/<=25¢)"
  - "Font sizes: Note 64pt medium (was 72pt bold), Cents 24pt regular, String 16pt/14pt rounded, Labels 14pt monospaced"
  - "Asset catalog structure follows Xcode convention with luminosity appearance variants"
metrics:
  duration: 5
  completed-date: 2026-03-12
  tests-passing: 170
---

# Phase 4 Plan 5: Colors and Typography Summary

Created semantic color assets with light/dark variants and applied proper typography using SF Pro Rounded and SF Mono throughout the tuner interface.

---

## What Was Built

### Color Assets

Created `Colors.xcassets` with three semantic colors supporting automatic light/dark mode adaptation:

| Color | Light Mode | Dark Mode | Usage |
|-------|------------|-----------|-------|
| InTuneGreen | #34C759 | #32D74B | In-tune state, tuned indicators |
| WarningOrange | #FF9500 | #FF9F0A | Warning/off-tune state |
| ErrorRed | #FF3B30 | #FF453A | Error/far off-tune state |

**Asset Structure:**
```
Resources/Colors.xcassets/
├── InTuneGreen.colorset/Contents.json
├── WarningOrange.colorset/Contents.json
└── ErrorRed.colorset/Contents.json
```

Each color defines:
- Universal idiom (works on all platforms)
- sRGB color space with floating-point components
- Light variant (default, no appearance specified)
- Dark variant (appearance: luminosity, value: dark)

### Typography Updates

Applied consistent typography across all views:

| Element | Font | Size | Weight | Design |
|---------|------|------|--------|--------|
| Note name | SF Pro Rounded | 64 | Medium | .rounded |
| Cents | SF Mono | 24 | Regular | .monospaced |
| String label | SF Pro Rounded | 16 | Regular | .rounded |
| String number | SF Pro Rounded | 14 | Regular | .rounded |
| Reference pitch | SF Mono | 14 | Regular | .monospaced |

### View Updates

#### CentsReadoutView
- Uses SF Mono 24pt regular for numeric stability
- Color thresholds: <5¢ green, <20¢ orange, >=20¢ red
- Semantic color assets for proper dark mode support

#### NoteDisplayView
- Uses SF Pro Rounded 64pt medium (was 72pt bold)
- InTuneGreen color when in tune
- Secondary color when no note detected

#### StringRailView
- String labels: SF Pro Rounded 16pt
- String numbers: SF Pro Rounded 14pt
- Tuned indicator uses InTuneGreen asset

#### ReferencePitchDisplay
- Uses SF Mono 14pt regular
- Secondary foreground style

#### TunerGaugeView
- Color zones use InTuneGreen and WarningOrange assets
- Needle color uses semantic colors based on deviation
- In-tune glow uses InTuneGreen asset

---

## Implementation Details

### Color Asset JSON Structure

```json
{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.200",
          "green": "0.780",
          "blue": "0.349",
          "alpha": "1.000"
        }
      },
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ]
    },
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.204",
          "green": "0.780",
          "blue": "0.349",
          "alpha": "1.000"
        }
      }
    }
  ]
}
```

### Typography Pattern

```swift
// SF Pro Rounded for UI elements
Text(noteName)
    .font(.system(size: 64, weight: .medium, design: .rounded))

// SF Mono for numeric data
Text("\(sign)\(intCents)")
    .font(.system(size: 24, weight: .regular, design: .monospaced))

// Semantic colors
.foregroundColor(Color("InTuneGreen"))
```

### Color Threshold Logic

```swift
private var centsColor: Color {
    guard let cents = cents else { return .secondary }
    let absCents = abs(Int(round(cents)))
    if absCents < 5 { return Color("InTuneGreen") }
    if absCents < 20 { return Color("WarningOrange") }
    return Color("ErrorRed")
}
```

---

## Files Created

| File | Purpose |
|------|---------|
| `Resources/Colors.xcassets/InTuneGreen.colorset/Contents.json` | Green color asset with light/dark variants |
| `Resources/Colors.xcassets/WarningOrange.colorset/Contents.json` | Orange color asset with light/dark variants |
| `Resources/Colors.xcassets/ErrorRed.colorset/Contents.json` | Red color asset with light/dark variants |

## Files Modified

| File | Changes |
|------|---------|
| `Sources/Views/TunerGaugeView.swift` | Color zones use asset colors, needle uses semantic colors, glow uses InTuneGreen |
| `Sources/Views/CentsReadoutView.swift` | SF Mono 24pt, semantic color thresholds |
| `Sources/Views/NoteDisplayView.swift` | SF Pro Rounded 64pt medium, InTuneGreen for in-tune |
| `Sources/Views/StringRailView.swift` | SF Pro Rounded 16pt/14pt, InTuneGreen for tuned indicator |
| `Sources/Views/ReferencePitchDisplay.swift` | SF Mono 14pt regular |

---

## Commits

| Hash | Message |
|------|---------|
| 048457e | feat(phase-04-05): add InTuneGreen color asset with light/dark variants |
| 106937b | feat(phase-04-05): add WarningOrange color asset with light/dark variants |
| cb22c1c | feat(phase-04-05): add ErrorRed color asset with light/dark variants |
| 0ba89be | feat(phase-04-05): update typography and semantic colors across views |
| 60609b1 | feat(phase-04-05): update TunerGaugeView to use semantic color assets |

---

## Test Results

All 170 tests pass:
- 137 existing tests (no regressions)
- 33 style tests

Build completed successfully with no errors.

---

## Deviations from Plan

### None - Plan Executed Exactly

All tasks completed as specified:
- InTuneGreen.colorset exists with light/dark sRGB values
- WarningOrange.colorset exists with light/dark sRGB values
- ErrorRed.colorset exists with light/dark sRGB values
- All colors use sRGB color space with luminosity appearance variants
- NoteDisplayView uses SF Pro Rounded 64pt medium
- CentsReadoutView uses SF Mono 24pt regular with semantic colors
- ReferencePitchDisplay uses SF Mono 14pt regular
- StringRailView uses SF Pro Rounded 16pt/14pt
- TunerGaugeView uses Color("InTuneGreen") for glow and color zones
- Color thresholds match specification (<5¢ green, <20¢ orange, >=20¢ red)

---

## Self-Check: PASSED

- [x] InTuneGreen.colorset/Contents.json exists
- [x] WarningOrange.colorset/Contents.json exists
- [x] ErrorRed.colorset/Contents.json exists
- [x] Commit 048457e exists (InTuneGreen asset)
- [x] Commit 106937b exists (WarningOrange asset)
- [x] Commit cb22c1c exists (ErrorRed asset)
- [x] Commit 0ba89be exists (typography updates)
- [x] Commit 60609b1 exists (TunerGaugeView color updates)
- [x] All 170 tests passing


---

## Usage Examples

### Color Assets
```swift
// Colors automatically adapt to light/dark mode
Text("In Tune")
    .foregroundColor(Color("InTuneGreen"))

Text("Warning")
    .foregroundColor(Color("WarningOrange"))

Text("Error")
    .foregroundColor(Color("ErrorRed"))
```

### Typography
```swift
// Note display
Text("A4")
    .font(.system(size: 64, weight: .medium, design: .rounded))

// Cents readout
Text("+5")
    .font(.system(size: 24, weight: .regular, design: .monospaced))

// Reference pitch
Text("A4 = 440.0 Hz")
    .font(.system(size: 14, weight: .regular, design: .monospaced))
```

---

## Phase 4 Complete

This plan completes Phase 4 (Window, Design Language, and Polish). All success criteria met:

- [x] Custom dark vibrant title bar (04-01)
- [x] Unified toolbar with glass pill styling (04-02)
- [x] Glass card design for gauge with 24pt radius (04-03)
- [x] Spring animations for needle, glow, and string selection (04-04)
- [x] Color assets with light/dark variants (04-05)
- [x] Typography with SF Pro Rounded and SF Mono (04-05)
- [x] Semantic color usage throughout (04-05)

Ready for Phase 5: NAM Integration.
