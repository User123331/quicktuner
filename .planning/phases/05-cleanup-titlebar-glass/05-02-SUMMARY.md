---
phase: 05-cleanup-titlebar-glass
plan: 02
status: complete
subsystem: app-window
tags: [title-bar, traffic-lights, vibrancy, glass, layout]
dependency_graph:
  requires: [05-01]
  provides: [visible-traffic-lights, true-vibrancy, traffic-light-safe-layout]
  affects: [AppDelegate, ContentView]
tech_stack:
  added: []
  patterns: [NSWindow transparency, macOS title bar chrome, directional SwiftUI padding]
key_files:
  modified:
    - Source/App/AppDelegate.swift
    - Source/App/ContentView.swift
decisions:
  - Re-enabling isOpaque=false + backgroundColor=.clear enables true vibrancy (glass refracts desktop, not window background)
  - Top padding set to 52pt (title bar ~28pt + comfortable spacing) to prevent content overlap with traffic lights
  - Settings gear top padding set to 12pt to vertically align with the standard macOS traffic light zone
metrics:
  duration: 5 minutes
  completed: 2026-03-13
  tasks_completed: 2
  files_modified: 2
---

# Phase 5 Plan 02: Title Bar & True Vibrancy Summary

**One-liner:** Revealed traffic light buttons, re-enabled window transparency for true desktop vibrancy, and adjusted content padding to clear the title bar zone.

## What Was Done

Removed the three lines in AppDelegate that were hiding the macOS close/minimize/zoom traffic light buttons, restored window transparency (isOpaque=false, backgroundColor=.clear) so the Liquid Glass effects refract against actual desktop content rather than the opaque window background, and updated ContentView padding to ensure the tuner gauge and settings gear clear the traffic light area.

## Changes Made

### Source/App/AppDelegate.swift

**Change 1 — Revealed traffic lights:**
Removed `window.standardWindowButton(.closeButton)?.isHidden = true`, `.miniaturizeButton`, and `.zoomButton` lines. The `titlebarAppearsTransparent` and `titleVisibility = .hidden` settings remain — they keep the title bar transparent while letting traffic lights show through.

**Change 2 — Enabled true vibrancy:**
Added `window.isOpaque = false` and `window.backgroundColor = .clear` before `isMovableByWindowBackground`. Without these, glass effects refract against the opaque window background color. With them, glass refracts against whatever is on the desktop behind the window.

### Source/App/ContentView.swift

**Change 1 — Top padding for traffic light clearance:**
Changed `TunerView().padding(24)` to directional padding: `.padding(.top, 52)` / `.padding(.horizontal, 24)` / `.padding(.bottom, 24)`. The 52pt top value clears the title bar height (~28pt) plus spacing.

**Change 2 — Settings gear alignment with traffic lights:**
Changed settings button `.padding(.top, 16)` to `.padding(.top, 12)`. This places the gear icon at the same vertical center as the standard macOS traffic light buttons (~12pt from the window top edge).

## Verification Results

Build output:
```
Build complete! (2.71s)
```

Zero errors, zero warnings. Both modified files compiled cleanly (Compiling QuickTuner ContentView.swift, Compiling QuickTuner AppDelegate.swift confirmed in output).

Grep checks:
- No `isHidden` lines remain in AppDelegate.swift
- `window.isOpaque = false` present at line 54
- `window.backgroundColor = .clear` present at line 55
- `.padding(.top, 52)` present in ContentView.swift
- `.padding(.top, 12)` present for settings button

## Deviations from Plan

None — plan executed exactly as written.

## Self-Check: PASSED

- Source/App/AppDelegate.swift — modified and committed
- Source/App/ContentView.swift — modified and committed
- Commit 90bdc40 exists and contains both files
