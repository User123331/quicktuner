# Roadmap: QuickTuner

## Overview

QuickTuner is built bottom-up in six phases: first the real-time audio pipeline (highest risk), then the core tuning interface with string-by-string workflow, then the tuning library and persistence layer, then visual design polish with Liquid Glass and floating window behavior, then cleanup, title bar, and proper Liquid Glass application, and finally audio device selection, input level monitoring, and UI bug fixes. Each phase delivers a verifiable capability that the next phase builds on.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Pitch Detection and Audio Engine** - Real-time audio capture and sub-cent pitch detection via YIN + FFT
- [x] **Phase 2: Tuner Interface and String Workflow** - Circular gauge, string navigation, and in-tune detection UI
- [x] **Phase 3: Tuning Library, Settings, and Persistence** - Instrument modes, preset/custom tunings, reference pitch, and persistent preferences
- [x] **Phase 4: Window, Design Language, and Polish** - Floating window, Liquid Glass design, spring animations, and typography
- [x] **Phase 5: Cleanup, Title Bar, and Liquid Glass** - Fix errors/warnings, add macOS title bar, and properly apply visible Liquid Glass effects
- [x] **Phase 6: Audio Verification and UI Fixes** - Audio device selection, input level meter, and custom tuning creator layout fix
- [x] **Phase 7: Gauge and Meter Redesign** - 240° speedometer gauge with classic analog needle, trig-based tick marks with labels, and VU meter fix (completed 2026-03-13)
- [x] **Phase 8: UI Polish and Bug Fixes** - Horizontal linear gauge, text wrapping fix (completed 2026-03-14)
- [x] **Phase 9: Window Compactness and Settings Polish** - Smaller window, locked size, enhanced reference pitch content, full-width input meter

## Phase Details

### Phase 8: UI Polish and Bug Fixes
**Goal**: Fix three critical UI issues discovered in Phase 7 verification: needle "flying" effect, gauge artifacts, and awkward text wrapping
**Depends on**: Phase 7
**Requirements**: PITCH-02, UI-01
**Status**: Planning - researching alternative gauge designs
**Success Criteria** (what must be TRUE):
  1. Needle clearly rotates around a single pivot point without appearing to "fly"
  2. Gauge displays cleanly without visual artifacts (radial lines, glitches)
  3. Custom Tuning Creator text layout is clean with no awkward wrapping
**Options**:
  - **A: Linear Gauge (Horizontal)** - Simple horizontal slider with vertical needle indicator
  - **B: Simplified Circular** - Keep circular concept but use only built-in SwiftUI shapes
  - **C: Vertical Linear** - Vertical bar gauge, very clean and minimal
  - **D: Fix Current Design** - Debug and fix the 240° gauge implementation
**Plans**: To be created after design decision

## Phase Details

### Phase 1: Pitch Detection and Audio Engine
**Goal**: User's microphone input is captured and analyzed in real time, producing accurate pitch data with noise rejection and reliable device handling
**Depends on**: Nothing (first phase)
**Requirements**: PITCH-01, PITCH-06, AUDIO-01, AUDIO-02, AUDIO-03, AUDIO-04
**Success Criteria** (what must be TRUE):
  1. App captures audio from the selected input device and detects pitch in real time with sub-cent accuracy across guitar and bass frequency ranges (31 Hz to 1300 Hz)
  2. User can select from all available Core Audio input devices (built-in mic, USB interface, etc.) and the selection persists between launches
  3. App displays a live input level meter confirming signal is being received
  4. App handles audio device hot-plug and unplug without crashing or freezing
  5. Background noise below the sensitivity threshold does not trigger false pitch detections
**Plans**: 5 plans in 5 waves

Plans:
- [x] 01-01: Models and NoteClassifier - Data structures and Hz-to-note classification with tests
- [x] 01-02: YIN Pitch Detector - Full YIN algorithm with cubic interpolation and unit tests
- [x] 01-03: AudioEngine and RingBuffer - Three-layer threading with lock-free ring buffer
- [x] 01-04: Audio Device Manager - Core Audio enumeration with Objective-C++ bridge
- [x] 01-05: Integration and Tests - TunerViewModel, basic UI, integration tests

### Phase 2: Tuner Interface and String Workflow
**Goal**: User sees a fully functional tuning interface with gauge, note display, cents readout, and can navigate string-by-string through the tuning process
**Depends on**: Phase 1
**Requirements**: PITCH-02, PITCH-03, PITCH-04, PITCH-05, NAV-01, NAV-02, NAV-03, NAV-04, NAV-05
**Success Criteria** (what must be TRUE):
  1. User sees a circular gauge with a needle that moves in real time to show how sharp or flat the current pitch is
  2. User sees the detected note name and octave (e.g., "E2") and a numeric cents offset readout
  3. When pitch is within +/-2 cents of the target, the display shows a green glow and check mark confirming in-tune status
  4. User can navigate between strings using arrow keys or by clicking string pills in a horizontal rail, with the active string visually highlighted
  5. When all strings show a check mark, user sees an "All Tuned" confirmation badge
**Plans**: 5 plans in 5 waves

Plans:
- [x] 02-01: ViewModel and Models - TunerViewModel, StringInfo, EMA smoothing with tests
- [x] 02-02: Gauge Component - Canvas-based TunerGaugeView, CentsReadoutView, NoteDisplayView
- [x] 02-03: String Rail and Navigation - StringRailView with keyboard (arrows + 1-6), click handling
- [x] 02-04: In-Tune Logic and Visuals - 200ms hold state machine, checkmarks, green glow
- [x] 02-05: Integration and "All Tuned" Flow - TunerView integration, badge, reset functionality

### Phase 3: Tuning Library, Settings, and Persistence
**Goal**: User can choose instruments, select from a comprehensive tuning library, create custom tunings, adjust reference pitch, and have all preferences remembered across launches
**Depends on**: Phase 2
**Requirements**: TUNE-01, TUNE-02, TUNE-03, TUNE-04, TUNE-05, TUNE-06, TUNE-07, PREF-01, PREF-02, PREF-03
**Success Criteria** (what must be TRUE):
  1. User can switch between Guitar (6-string) and Bass (4-string) modes and the string rail updates accordingly
  2. User can select from 15+ preset tunings (standard, Drop D, DADGAD, Open G, etc.) and the target notes for each string update immediately
  3. User can adjust reference pitch from 420-444 Hz via a dial/slider and one-click presets (440, 432, 443), with the current reference displayed near the gauge
  4. User can create, name, and save custom tunings that appear alongside presets in the tuning selector
  5. Selected tuning, reference pitch, and custom tunings all persist across app restarts
**Plans**: TBD

Plans:
- [x] 03-01: Tuning Models and Library - Tuning, TuningNote, InstrumentType, TuningLibrary with 37 presets
- [x] 03-02: Persistence Service - Constants, PersistenceService, TunerViewModel integration

### Phase 4: Window, Design Language, and Polish
**Goal**: The app looks and feels like a native macOS precision instrument with Liquid Glass design, smooth animations, and a compact floating window
**Depends on**: Phase 3
**Requirements**: UI-01, UI-02, UI-03, UI-04, UI-05
**Success Criteria** (what must be TRUE):
  1. App runs as a compact, draggable floating window that can optionally stay on top of other windows
  2. Interface uses translucent panels with vibrancy blur and refractive highlights consistent with Apple's Liquid Glass design language
  3. App defaults to dark mode and fully supports light mode with correct semantic colors throughout
  4. Needle movement, string transitions, and in-tune glow use spring-driven animations that feel physically weighted
  5. Typography uses SF Pro Rounded for labels and SF Mono for numeric readouts (cents/Hz)
**Plans**: TBD

Plans:
- [x] 04-COR: Liquid Glass Correction - Fix transparent window, apply macOS 26 .glassEffect() API correctly, fix Package.swift paths
- [x] 04-FIX-03: Ultra-Thin Material Opacity - Reduce window background opacity to 0.4 for ultra-thin liquid glass
- [x] 04-FIX-02: Remove glassCard Container - TunerGaugeView floats directly on window background without panel
- [x] 04-FIX-01: 8-String Overflow Fix - Horizontal ScrollView wrapper for StringRailView to support multi-string instruments
- [x] 04-GAP-03: Tuner Gauge Redesign - Triangle needle with shadow, multi-layer glow, gradient color zones
- [x] 04-GAP-04: Settings Button - Gear icon overlay in top-right with glass styling and sheet presentation
- [x] 04-GAP-02: Remove Focus Rings - .focusEffectDisabled on ContentView and StringPill for clean glass aesthetic
- [x] 04-GAP-01: Fix Missing Liquid Glass Effects - Window transparency and ignoresSafeArea for material visibility
- [x] 04-01: Window Configuration - Floating panel, position persistence, multi-monitor support

### Phase 5: Cleanup, Title Bar, and Liquid Glass
**Goal**: The app has zero build errors/warnings, a proper macOS title bar, and visually prominent Liquid Glass effects that are clearly visible to the user
**Depends on**: Phase 4
**Requirements**: POLISH-01, POLISH-02, POLISH-03
**Success Criteria** (what must be TRUE):
  1. Project builds with zero errors and zero warnings (clean build)
  2. App has a proper macOS title bar (transparent, integrated with Liquid Glass) that provides standard window controls
  3. Liquid Glass effects are clearly visible — translucent glass panels with blur, refractive highlights, and depth that the user can actually see
  4. All UI components (gauge container, string pills, settings button, tuning selector) show distinct glass surfaces
  5. Glass effects respond to content behind the window (true vibrancy, not just tinted backgrounds)
**Plans**: 3 plans in 3 waves

Plans:
- [x] 05-01: Build Warning Fixes + Git Cleanup - Fix all compiler/SPM warnings, clean stale git index
- [x] 05-02: Title Bar + Window Transparency - Show traffic lights, enable true vibrancy
- [x] 05-03: Glass Layering Corrections - Remove glass stacking anti-pattern, fix TuningSelector, GlassEffectContainer for string rail

### Phase 6: Audio Verification and UI Fixes
**Goal**: The app correctly captures audio from the system default device (or user-selected device), displays a live input level meter, and all UI forms are visually correct
**Depends on**: Phase 5
**Requirements**: AUDIO-01, AUDIO-02, AUDIO-03, AUDIO-04, FIX-01
**Success Criteria** (what must be TRUE):
  1. Audio device selection works — user can pick from available Core Audio input devices (replacing the "System Default / Coming in Phase 4" placeholder)
  2. Audio device selection persists between app launches
  3. A live input level meter is visible confirming signal presence when audio is being received
  4. App handles audio device hot-plug/unplug gracefully without crashing
  5. Custom tuning creator "Octave" picker label is not word-wrapped — displays cleanly on a single line
**Plans**: 3 plans in 2 waves

Plans:
- [x] 06-01: ViewModel Sharing — Lift TunerViewModel to ContentView, update TunerView and SettingsView wiring
- [x] 06-02: AudioSettings Rewrite — Device picker, InputLevelMeter component, noise gate binding fix
- [x] 06-03: Octave Picker Fix — Widen frame from 70 to 90 in CustomTuningCreator
- [x] 06-GAP-01: Gauge Geometry Fix — Replace Canvas with SwiftUI geometry, fix angle math, adaptive EMA, needle spring tuning
- [x] 06-GAP-02: Cents & Meter UX — Enhanced CentsReadoutView with unit label and tighter zones, segmented InputLevelMeter with fixed color zones

### Phase 7: Gauge and Meter Redesign
**Goal**: The tuner gauge is a proper 240° speedometer-style analog gauge with a classic needle and counterweight, trig-based tick marks with numeric labels, and the VU meter renders slim vertical bars
**Depends on**: Phase 6
**Requirements**: PITCH-02, AUDIO-02
**Success Criteria** (what must be TRUE):
  1. Gauge arc spans 240° (speedometer shape, open at bottom-center) — not a compass or semicircle
  2. Tick marks are placed on the arc using sin/cos from the gauge pivot — not scattered from wrong anchor rotation
  3. Major ticks at -50, -25, 0, +25, +50 have numeric labels just outside the arc in SF Mono
  4. Needle has a thin shaft (pointing up from pivot) and a teardrop counterweight stub (below pivot)
  5. VU meter segments are slim vertical bars (~8pt wide) — not wide tiles stretching to fill container
**Plans**: 2 plans in 1 wave

Plans:
- [ ] 07-01-PLAN.md — Gauge rewrite: 240° arc, trig-based ticks + labels, NeedleShaft + CounterweightShape, updated tests
- [ ] 07-02-PLAN.md — VU meter fix: explicit segmentWidth per RoundedRectangle segment in InputLevelMeter

### Phase 8: UI Polish and Bug Fixes
**Goal**: Fix three critical UI issues discovered in Phase 7 verification: needle "flying" effect, gauge artifacts, and awkward text wrapping
**Depends on**: Phase 7
**Requirements**: PITCH-02, UI-01
**Status**: In Progress
**Success Criteria** (what must be TRUE):
  1. Needle clearly rotates around a single pivot point without appearing to "fly"
  2. Gauge displays cleanly without visual artifacts (radial lines, glitches)
  3. Custom Tuning Creator text layout is clean with no awkward wrapping
**Plans**: 2 plans planned

Plans:
- [x] 08-01-PLAN.md — Horizontal linear gauge: Replace 240° arc with clean horizontal bar, sliding Capsule needle
- [x] 08-02-PLAN.md — Text wrapping fix: Fix "octave" label in CustomTuningCreator

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Pitch Detection and Audio Engine | 5/5 | Complete | 2026-03-11 |
| 2. Tuner Interface and String Workflow | 5/5 | Complete | 2026-03-11 |
| 3. Tuning Library, Settings, and Persistence | 5/5 | Complete | 2026-03-12 |
| 4. Window, Design Language, and Polish | 9/9 | Complete | 2026-03-13 |
| 5. Cleanup, Title Bar, and Liquid Glass | 3/3 | Complete | 2026-03-13 |
| 6. Audio Verification and UI Fixes | 4/4 | Complete | 2026-03-13 |
| 7. Gauge and Meter Redesign | 2/2 | Complete | 2026-03-13 |
| 8. UI Polish and Bug Fixes | 2/2 | Complete | 2026-03-14 |
| 9. Window Compactness and Settings Polish | 3/3 | Complete    | 2026-03-14 |

### Phase 9: Window Compactness and Settings Polish

**Goal:** Reduce window size to 440x480, lock window dimensions, remove fullscreen button, enhance Reference Pitch content with brief descriptions, and fix Input Level meter to fill 90% of settings panel width
**Requirements**: UI-01, UI-05
**Depends on:** Phase 8
**Status:** Complete - 3 plans executed
**Success Criteria** (what must be TRUE):
  1. Window opens at 440x480 and cannot be resized
  2. Fullscreen button is removed from title bar
  3. Layout feels compact without excess vertical space
  4. Reference Pitch section shows enhanced bullet descriptions (1-2 sentences per frequency)
  5. Input Level meter extends 90% of settings panel width with dynamic segment scaling
**Plans:** 3/3 plans complete

Plans:
- [x] 09-01-PLAN.md — Window sizing and lock: Update dimensions to 440x480, disable resize and fullscreen
- [x] 09-02-PLAN.md — Layout compactness and reference pitch: Remove Spacer, enhance descriptions
- [x] 09-03-PLAN.md — Input level meter dynamic width: GeometryReader for 90% fill, dynamic segments