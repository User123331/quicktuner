# QuickTuner

**A macOS-native chromatic guitar & bass tuner with customizable reference pitch.**

---

## Concept

QuickTuner is a lightweight, always-ready instrument tuner that lives in the macOS menu bar or as a compact floating window. It guides players string-by-string through standard and alternate tunings with a single-string-focus workflow — tap or arrow-key between strings, tune each one, move on. Reference pitch is adjustable from 420–444 Hz for orchestral, historical, or experimental contexts.

The interface follows Apple's Liquid Glass design language: translucent layered panels, vibrancy blur, depth-of-field material effects, and subtle refractive highlights. It should feel like a precision instrument built into the OS.

---

## Core Features

**String-by-String Flow**
The UI centers on one active string at a time. A horizontal string rail at the bottom shows all strings (e.g. E A D G B E) as frosted-glass pills. The active string is expanded and glowing. Users navigate with left/right arrow keys, clicking a pill, or a simple swipe gesture. The tuner needle and pitch readout update instantly on switch — zero friction.

**Chromatic Needle + Cents Readout**
A large circular gauge with a floating glass needle shows pitch deviation in real time. Cents offset is displayed numerically below. When the string is in tune (±2 cents), the needle locks center with a satisfying haptic-style pulse animation and the gauge rim shifts to green.

**Reference Pitch Dial (420–444 Hz)**
A rotary knob or horizontal slider in the settings sheet lets users set the A4 reference frequency. The current value is always visible as a subtle label near the gauge (e.g. "A4 = 432 Hz"). Presets for 440 (standard), 432, and 443 (orchestral) are one-click accessible.

**Guitar / Bass Toggle**
A segmented control switches between Guitar (6-string) and Bass (4-string) modes. Each mode loads the correct string set and default tuning. Alternate tunings (Drop D, DADGAD, Half-Step Down, etc.) are selectable from a dropdown.

**Audio Input Selector**
A dropdown in settings lists available Core Audio input devices (built-in mic, USB interface, Bluetooth). Selection persists between launches. A small live-input level meter confirms signal.

---

## Design Direction — Liquid Glass

The entire window is a single translucent panel with `NSVisualEffectView` vibrancy. Key elements sit on layered frosted-glass cards with subtle inner shadows and light refraction borders. The tuning gauge uses a radial gradient that shifts with the system accent color. Typography is SF Pro Rounded for warmth, SF Mono for the cents/Hz readouts. Animations are spring-driven (SwiftUI `.spring()`) — the needle, string transitions, and in-tune glow all feel physically weighted. Dark mode is the default, with light mode fully supported via semantic colors.

---

## Tech Stack

| Layer | Choice | Rationale |
|---|---|---|
| **Language** | Swift 5.9+ | Native performance, first-class Apple framework access |
| **UI Framework** | SwiftUI (macOS 14+) | Declarative, animation-friendly, native Liquid Glass vibrancy support |
| **Audio Capture** | AVAudioEngine (Core Audio) | Low-latency tap on input node, device enumeration, format negotiation |
| **Pitch Detection** | Accelerate / vDSP (FFT) + autocorrelation (YIN algorithm) | Sub-cent accuracy at real-time speed on Apple Silicon; no third-party deps |
| **Signal Processing** | Accelerate framework | SIMD-optimized DSP primitives, runs identically on ARM64 and x86 |
| **Persistence** | UserDefaults + Codable | Lightweight storage for reference pitch, selected tuning, input device |
| **Build Target** | Universal Binary (arm64 + x86_64) | Single binary runs native on both Apple Silicon and Intel Macs |
| **Min Deployment** | macOS 14 Sonoma | Required for latest SwiftUI vibrancy/material APIs |
| **Distribution** | Notarized .dmg / Mac App Store | Gatekeeper-friendly, sandboxed with microphone entitlement |
| **Build System** | Xcode 15+ / Swift Package Manager | No external dependency manager needed |

---

## Architecture Sketch

```
┌─────────────────────────────────────────────┐
│                  SwiftUI View               │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐ │
│  │  Gauge   │  │  String  │  │ Settings  │ │
│  │  Needle  │  │  Rail    │  │  Sheet    │ │
│  └────┬─────┘  └────┬─────┘  └─────┬─────┘ │
│       │              │              │       │
│       ▼              ▼              ▼       │
│  ┌──────────────────────────────────────┐   │
│  │         TunerViewModel               │   │
│  │  @Published pitch / cents / inTune   │   │
│  │  selectedString, tuningPreset, refHz │   │
│  └──────────────┬───────────────────────┘   │
│                 │                            │
│  ┌──────────────▼───────────────────────┐   │
│  │        AudioEngine (actor)           │   │
│  │  AVAudioEngine → tap → ring buffer   │   │
│  │  input device selection              │   │
│  └──────────────┬───────────────────────┘   │
│                 │                            │
│  ┌──────────────▼───────────────────────┐   │
│  │      PitchDetector (Accelerate)      │   │
│  │  FFT → YIN autocorrelation → Hz      │   │
│  │  Hz → nearest note + cents offset    │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

---

## String-by-String UX Flow

```
 User opens QuickTuner
        │
        ▼
 Default: Guitar mode, String 1 (low E) active
        │
        ▼
 Tune string → needle centers → green glow + check mark
        │
        ▼
 Press → or click next pill → String 2 (A) active
        │
        ▼
 Repeat until all strings show ✓
        │
        ▼
 "All Tuned" confirmation badge appears
```

---

## Scope Boundaries

This is a focused, single-purpose utility. Out of scope for v1: recording, metronome, chord detection, MIDI output, and iOS/iPadOS. Keep it sharp.
