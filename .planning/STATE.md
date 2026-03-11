# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-11)

**Core value:** Real-time, sub-cent-accurate pitch detection with a frictionless string-by-string tuning flow that feels like a precision instrument built into the OS.
**Current focus:** Phase 4 Plan 1 COMPLETE - Window Configuration with floating window and position persistence

## Current Position

Phase: 4 of 4 (Window, Design Language, and Polish)
Plan: GAP-04 Complete - Settings Button Added
Status: **Phase 4 GAP-04 Complete - Settings gear button visible in top-right corner**
Last activity: 2026-03-12 -- Completed GAP-04 with settings button overlay and sheet presentation

Progress: [██████░░░░] 60% (Phase 4)

## Performance Metrics

**Velocity:**
- Total plans completed: 11
- Average duration: 8 minutes
- Total execution time: 1.5 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 02-tuner-interface | 5 | 5 | 12 min |
| 03-tuning-library | 5 | 5 | 10 min |
| 04-window-design | 4 | 5 | 4 min |

**Recent Trend:**
- Last 5 plans: 04-GAP-04 (3 min), 04-GAP-02 (1 min), 04-GAP-01 (5 min), 04-01 (3 min), 03-05 (15 min)
- Trend: faster for focused gap fixes

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Phase 4-GAP-04]: Settings button uses overlay approach (toolbar not visible with hidden title bar)
- [Phase 4-GAP-04]: Separate TunerViewModel instance for SettingsView avoids conflicts with TunerView's @State model
- [Phase 4-GAP-04]: Glass button styling with .ultraThinMaterial background and circular clip shape

- [Phase 4-GAP-02]: .focusEffectDisabled(true) applied at root (ContentView) and button level (StringPill) to eliminate macOS focus rings
- [Phase 4-GAP-02]: Modifier propagates down view hierarchy, covers all child views
- [Phase 4-GAP-01]: Window transparency (isOpaque = false, backgroundColor = .clear) required for material/vibrancy effects
- [Phase 4-GAP-01]: ignoresSafeArea() required on material background to fill entire window

- [Phase 4-01]: @MainActor required on WindowManager for NSWindow concurrency safety (Swift 6)
- [Phase 4-01]: NSKeyedArchiver used for frame persistence (not @AppStorage - cannot store NSRect)

- [Phase 3-05]: TuningNote properties changed to var to support SwiftUI bindings in CustomTuningCreator
- [Phase 3-05]: String rail displays low-to-high (standard guitar orientation) by reversing notes array
- [Phase 3-05]: Frequency calculation uses equal temperament formula with reference pitch
- [Phase 3]: Used .primary instead of .accent for foregroundStyle (ShapeStyle.accent unavailable in this SwiftUI version)
- [Phase 3]: Used explicit UserDefaults instead of @AppStorage for more control over persistence timing
- [Phase 3]: Actor-based PersistenceService for thread-safe file operations
- [Phase 3]: Atomic file writes (temp then move) to prevent corruption
- [Phase 2]: EMA smoothing alpha = 0.3 for optimal responsiveness/smoothing balance
- [Phase 2]: In-tune threshold ±2 cents with 1 cent hysteresis (PITCH-05)
- [Phase 2]: In-tune requires 200ms hold before confirming
- [Phase 2]: Checkmarks persist until manual reset
- [Phase 2]: "All Tuned" badge appears 500ms after last string tuned
- [Phase 2]: Task-based delay with cancellation for badge timing
- [Phase 2]: Canvas API chosen for Phase 4 Liquid Glass integration path
- [Phase 2]: SF Mono for cents readout (numeric stability)
- [Phase 2]: SF Pro Rounded for note display (modern appearance)
- [Roadmap]: 4-phase coarse structure -- DSP/Audio first (highest risk), then UI, then tunings/persistence, then visual polish

### Completed Requirements

- UI-02: Focus effects disabled (.focusEffectDisabled) for clean glass aesthetic
- UI-02: Liquid Glass material background with window transparency
- UI-01: Floating window always on top
- PITCH-02: EMA smoothing for gauge needle (alpha=0.3)
- PITCH-03: Note name and octave display
- PITCH-04: Numeric cents offset as integer
- PITCH-05: In-tune detection with 2 cent threshold
- NAV-01: Arrow key navigation (previous/next string)
- NAV-02: Number keys 1-6 for direct string selection
- NAV-04: Track tuned strings with visual confirmation
- NAV-05: All Tuned badge with 500ms delay
- PREF-01: Reference pitch persistence (420-444 Hz range)
- PREF-02: Instrument selection persistence
- PREF-03: Custom tunings persistence to JSON
- TUNE-01: Tuning data model with notes, instrument, category
- TUNE-02: TuningLibrary with preset and custom tunings
- TUNE-03: Reference pitch adjustment UI
- TUNE-04: Reference pitch presets (440, 432, 420)
- TUNE-05: Reference pitch display on main UI
- TUNE-06: Instrument/tuning selection persistence
- TUNE-07: Custom tuning creation and persistence
- TUNE-08: Tuning selector always visible on main UI
- TUNE-09: String rail updates with tuning changes

### Phase 3 Success Criteria Met

All Phase 3 requirements completed:
- Tuning data models (TuningNote, Tuning, InstrumentType, TuningCategory)
- TuningLibrary service with 37 preset tunings
- PersistenceService with atomic JSON writes
- SettingsView with TabView (Reference Pitch, Tuning Library, Audio, About)
- TuningSelector always visible on main UI
- InstrumentPicker with 6 instrument types
- CustomTuningCreator with note/octave pickers
- StringRailView with dynamic updates
- All persistence requirements (PREF-01, PREF-02, PREF-03)
- 137 tests passing

### Pending Todos

Ready for Phase 4 Plan 03: Typography and Animation Polish

### Blockers/Concerns

- None

## Session Continuity

Last session: 2026-03-12
Stopped at: Phase 4 GAP-04 COMPLETE -- Settings gear button with overlay and sheet presentation
Resume file: Phase 4 Plan 03

---

## Phase 4 GAP-04 Summary

**Components Added:**
- Settings gear button in top-right corner using VStack/HStack/Spacer overlay pattern
- Glass styling: .ultraThinMaterial background with circular clip shape
- Sheet presentation for SettingsView with separate TunerViewModel instance

**Files Modified:**
- Sources/App/ContentView.swift

**Build Status:** Passing

## Phase 4 GAP-02 Summary

**Components Fixed:**
- ContentView root view with .focusEffectDisabled(true)
- StringPill button with .focusEffectDisabled(true)

**Files Modified:**
- Sources/App/ContentView.swift
- Sources/Views/StringPill.swift

**Build Status:** Succeeded

---

## Phase 4 GAP-01 Summary

**Components Fixed:**
- ContentView material background with ignoresSafeArea()
- AppDelegate window transparency (isOpaque = false, backgroundColor = .clear)

**Files Modified:**
- Sources/App/ContentView.swift
- Sources/App/AppDelegate.swift

**Build Status:** Code compiles, changes ready for visual verification

---

## Phase 4 Plan 1 Summary

**Components Built:**
- WindowManager with NSKeyedArchiver frame persistence
- AppDelegate with NSPanel floating configuration
- QuickTunerApp updated with hidden title bar and AppDelegate adaptor
- Multi-monitor support with screen validation
- Dock restore handling
- Screen change observer with position clamping

**Build Status:** Passing (137 tests)

**Components Built:**
- TuningNote, TuningCategory, InstrumentType, Tuning models
- TuningLibrary service with 37 preset tunings
- PresetTunings data with comprehensive tuning library
- Constants.swift with persistence keys and reference pitch constants
- PersistenceService with atomic JSON writes
- TunerViewModel persistence integration
- SettingsView with TabView (Reference Pitch, Tuning Library, Audio, About)
- ReferencePitchSettings with stepper and preset buttons
- TuningLibrarySettings with instrument picker and tuning list
- AudioSettings with noise gate slider
- AboutSettings with app info
- ReferencePitchDisplay component for main UI
- Immediate recalculation on reference pitch change
- InstrumentPicker component (6 instrument types)
- TuningSelector component (always visible)
- CustomTuningCreator form with note/octave pickers
- StringRailView with dynamic string generation
- Frequency calculation using equal temperament

**Tests:** 137 total
**Build Status:** Passing
**Integration:** Complete
