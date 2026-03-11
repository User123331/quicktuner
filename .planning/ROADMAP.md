# Roadmap: QuickTuner

## Overview

QuickTuner is built bottom-up in four phases: first the real-time audio pipeline (highest risk), then the core tuning interface with string-by-string workflow, then the tuning library and persistence layer, and finally the visual design polish with Liquid Glass and floating window behavior. Each phase delivers a verifiable capability that the next phase builds on.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Pitch Detection and Audio Engine** - Real-time audio capture and sub-cent pitch detection via YIN + FFT
- [x] **Phase 2: Tuner Interface and String Workflow** - Circular gauge, string navigation, and in-tune detection UI
- [ ] **Phase 3: Tuning Library, Settings, and Persistence** - Instrument modes, preset/custom tunings, reference pitch, and persistent preferences
- [ ] **Phase 4: Window, Design Language, and Polish** - Floating window, Liquid Glass design, spring animations, and typography

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
- [ ] 03-01: TBD
- [ ] 03-02: TBD

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
- [ ] 04-01: TBD
- [ ] 04-02: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Pitch Detection and Audio Engine | 5/5 | Complete | 2026-03-11 |
| 2. Tuner Interface and String Workflow | 5/5 | Complete | 2026-03-11 |
| 3. Tuning Library, Settings, and Persistence | 0/? | Not started | - |
| 4. Window, Design Language, and Polish | 0/? | Not started | - |
