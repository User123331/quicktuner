# QuickTuner

## What This Is

A macOS-native chromatic guitar and bass tuner that runs as a compact floating window. It guides players string-by-string through standard and alternate tunings with a single-string-focus workflow — tap or arrow-key between strings, tune each one, move on. Reference pitch is adjustable from 420–444 Hz for orchestral, historical, or experimental contexts. The interface follows Apple's Liquid Glass design language with translucent panels, vibrancy blur, and spring-driven animations.

## Core Value

Real-time, sub-cent-accurate pitch detection with a frictionless string-by-string tuning flow that feels like a precision instrument built into the OS.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Real-time chromatic pitch detection via YIN autocorrelation + FFT
- [ ] Circular gauge with floating glass needle showing pitch deviation
- [ ] Numeric cents offset readout
- [ ] In-tune detection (±2 cents) with visual confirmation (green glow, check mark)
- [ ] String-by-string navigation via arrow keys, click, or swipe
- [ ] Horizontal string rail with frosted-glass pill indicators
- [ ] Guitar mode (6-string) and Bass mode (4-string) via segmented control
- [ ] Comprehensive preset tuning library (15+ tunings: standard, drop, open, modal, bass variants)
- [ ] User-defined custom tunings (name and save custom note-per-string configurations)
- [ ] Reference pitch dial adjustable 420–444 Hz with presets (440, 432, 443)
- [ ] Audio input device selector (Core Audio enumeration)
- [ ] Live input level meter
- [ ] Persistent settings (reference pitch, selected tuning, input device)
- [ ] Floating window mode (compact, draggable, always-on-top optional)
- [ ] "All Tuned" confirmation badge when all strings show ✓
- [ ] Liquid Glass design: translucent panels, vibrancy blur, refractive highlights
- [ ] Dark mode default with full light mode support via semantic colors
- [ ] Spring-driven animations (needle, string transitions, in-tune glow)

### Out of Scope

- Recording — not a DAW, focused single-purpose utility
- Metronome — separate tool, keep scope tight
- Chord detection — adds significant complexity, not core to string-by-string flow
- MIDI output — unnecessary for a visual tuner
- iOS/iPadOS — macOS-only for v1
- Menu bar mode — floating window only for v1
- Auto-detect string — manual string selection keeps UX predictable
- Launch at login — open on demand, no background process

## Context

- Target platform: macOS 14 Sonoma+ (required for latest SwiftUI vibrancy/material APIs)
- Built with Swift 5.9+, SwiftUI for UI, AVAudioEngine for audio capture
- Pitch detection via Accelerate/vDSP (FFT) + YIN autocorrelation — no third-party dependencies
- Universal Binary (arm64 + x86_64) for Apple Silicon and Intel Macs
- Distribution: notarized .dmg or Mac App Store, sandboxed with microphone entitlement
- Typography: SF Pro Rounded for warmth, SF Mono for cents/Hz readouts
- Architecture: SwiftUI views → TunerViewModel (@Published state) → AudioEngine (actor) → PitchDetector (Accelerate)

## Constraints

- **Platform**: macOS 14+ only — required for SwiftUI vibrancy and material APIs
- **Dependencies**: Zero external dependencies — Apple frameworks only (Accelerate, AVFoundation, SwiftUI)
- **Performance**: Pitch detection must run at real-time speed on both Apple Silicon and Intel
- **Audio**: Must handle Core Audio device enumeration, format negotiation, and low-latency tap
- **Sandbox**: App Store sandbox with microphone entitlement required

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Floating window only (no menu bar) | Simpler architecture, dedicated tuning workspace | — Pending |
| Manual string selection (no auto-detect) | Predictable UX, lower complexity, avoids false detections | — Pending |
| YIN + FFT for pitch detection | Sub-cent accuracy without third-party deps, proven algorithm | — Pending |
| macOS 14+ minimum | Required for Liquid Glass vibrancy APIs | — Pending |
| Comprehensive tuning library + custom tunings | Covers advanced players, differentiator vs basic tuners | — Pending |
| On-demand launch (no login item) | Single-purpose utility, no background resource usage | — Pending |

---
*Last updated: 2026-03-11 after initialization*
