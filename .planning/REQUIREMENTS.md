# Requirements: QuickTuner

**Defined:** 2026-03-11
**Core Value:** Real-time, sub-cent-accurate pitch detection with a frictionless string-by-string tuning flow that feels like a precision instrument built into the OS.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Pitch Detection

- [ ] **PITCH-01**: User hears pitch detected in real time with sub-cent accuracy using YIN autocorrelation + FFT
- [x] **PITCH-02**: User sees a circular gauge with an animated floating glass needle showing pitch deviation
- [ ] **PITCH-03**: User sees the detected note name and octave prominently displayed (e.g., "E2", "A4")
- [ ] **PITCH-04**: User sees numeric cents offset readout at 1-cent resolution
- [ ] **PITCH-05**: User sees clear in-tune indication (±2 cents) with green glow and check mark animation
- [ ] **PITCH-06**: Pitch detection suppresses background noise via configurable noise gate / sensitivity threshold

### String Navigation

- [ ] **NAV-01**: User can navigate between strings using left/right arrow keys
- [ ] **NAV-02**: User can navigate between strings by clicking string pills in the horizontal rail
- [ ] **NAV-03**: User sees all strings displayed as frosted-glass pills with the active string expanded and glowing
- [ ] **NAV-04**: User sees per-string tuned status (check mark when string is in tune)
- [ ] **NAV-05**: User sees "All Tuned" confirmation badge when every string shows ✓

### Instrument & Tunings

- [ ] **TUNE-01**: User can switch between Guitar (6-string) and Bass (4-string) modes via segmented control
- [ ] **TUNE-02**: User can select from 15+ preset tunings (standard, Drop D, DADGAD, Open G/D/E, Half-Step Down, etc.)
- [ ] **TUNE-03**: User can adjust reference pitch from 420–444 Hz via rotary knob or slider
- [ ] **TUNE-04**: User can one-click select reference pitch presets (440, 432, 443 Hz)
- [ ] **TUNE-05**: User sees current reference pitch displayed near the gauge (e.g., "A4 = 432 Hz")
- [ ] **TUNE-06**: User can create, name, and save custom note-per-string tunings
- [ ] **TUNE-07**: User can select saved custom tunings from the tuning dropdown alongside presets

### Audio Input

- [ ] **AUDIO-01**: User can select from available Core Audio input devices (built-in mic, USB interface, etc.)
- [x] **AUDIO-02**: User sees a live input level meter confirming signal presence
- [ ] **AUDIO-03**: Audio input device selection persists between app launches
- [ ] **AUDIO-04**: App handles audio device hot-plug/unplug gracefully without crashing

### Window & Design

- [ ] **UI-01**: App runs as a compact floating window that stays on top of other windows
- [ ] **UI-02**: App uses Apple's Liquid Glass design language with translucent panels, vibrancy blur, and refractive highlights
- [ ] **UI-03**: Dark mode is the default appearance with full light mode support via semantic colors
- [ ] **UI-04**: Animations are spring-driven (needle movement, string transitions, in-tune glow) and feel physically weighted
- [ ] **UI-05**: Typography uses SF Pro Rounded for labels and SF Mono for numeric readouts (cents/Hz)

### Persistence

- [ ] **PREF-01**: User's selected tuning persists between app launches
- [ ] **PREF-02**: User's reference pitch setting persists between app launches
- [ ] **PREF-03**: User's saved custom tunings persist between app launches

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Precision & Display

- **PREC-01**: User can toggle sub-cent (0.1 cent) precision display for luthier/intonation work

### Instruments

- **INST-01**: User can select additional instrument profiles (ukulele, violin, etc.)
- **INST-02**: User can transpose for Bb/Eb instruments

### Audio

- **AUD2-01**: Tone generator / drone playback for ear training
- **AUD2-02**: Additional temperament modes (Pythagorean, meantone, Werckmeister)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Auto-detect string | Unreliable with detuned/alternate tunings; causes frustrating false detections |
| Polyphonic tuning | Extremely complex DSP via microphone; accuracy drops significantly |
| Menu bar mode | Constrains visual feedback; floating window is sufficient |
| Built-in metronome | Scope creep; separate tool, many free alternatives exist |
| Recording / playback | Different product category entirely |
| Chord detection | Fundamentally different DSP pipeline; not related to tuning |
| MIDI output | Extremely niche; unnecessary for visual tuner |
| iOS / iPadOS | Different platform and audio APIs; macOS-only for v1 |
| Launch at login | Wastes resources; microphone access while idle is a privacy concern |
| macOS 15 / Sequoia support | Targeting macOS 26 Tahoe only for native Liquid Glass |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| PITCH-01 | Phase 1 | Pending |
| PITCH-02 | Phase 2 | Complete |
| PITCH-03 | Phase 2 | Pending |
| PITCH-04 | Phase 2 | Pending |
| PITCH-05 | Phase 2 | Pending |
| PITCH-06 | Phase 1 | Pending |
| NAV-01 | Phase 2 | Pending |
| NAV-02 | Phase 2 | Pending |
| NAV-03 | Phase 2 | Pending |
| NAV-04 | Phase 2 | Pending |
| NAV-05 | Phase 2 | Pending |
| TUNE-01 | Phase 3 | Pending |
| TUNE-02 | Phase 3 | Pending |
| TUNE-03 | Phase 3 | Pending |
| TUNE-04 | Phase 3 | Pending |
| TUNE-05 | Phase 3 | Pending |
| TUNE-06 | Phase 3 | Pending |
| TUNE-07 | Phase 3 | Pending |
| AUDIO-01 | Phase 6 | Pending |
| AUDIO-02 | Phase 6 | Complete |
| AUDIO-03 | Phase 6 | Pending |
| AUDIO-04 | Phase 6 | Pending |
| UI-01 | Phase 4 | Pending |
| UI-02 | Phase 4 | Pending |
| UI-03 | Phase 4 | Pending |
| UI-04 | Phase 4 | Pending |
| UI-05 | Phase 4 | Pending |
| PREF-01 | Phase 3 | Pending |
| PREF-02 | Phase 3 | Pending |
| PREF-03 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 30
- Unmapped: 0

---
*Requirements defined: 2026-03-11*
*Last updated: 2026-03-11 after roadmap creation*
