---
phase: 05-cleanup-titlebar-glass
plan: 03
status: complete
subsystem: ui/glass-architecture
tags: [glass, liquid-glass, swiftui, macos26, anti-pattern-fix]
dependency_graph:
  requires: [05-02]
  provides: [clean-glass-architecture]
  affects: [ContentView, TuningSelector, StringRailView]
tech_stack:
  added: []
  patterns: [GlassEffectContainer, glassCard, version-gating]
key_files:
  modified:
    - Source/App/ContentView.swift
    - Source/Views/TuningSelector.swift
    - Source/Views/StringRailView.swift
decisions:
  - No glass on ContentView root — window background is transparent from Plan 02, glass components refract against desktop
  - TuningSelector.glassCard(cornerRadius:16) provides version-gated glass consistent with Phase 4 COR
  - GlassEffectContainer groups string rail pills into one refractive sampling context on macOS 26+
metrics:
  duration: 8 minutes
  completed: 2026-03-13
  tasks: 3
  files_changed: 3
---

# Phase 5 Plan 03: Glass Architecture Cleanup Summary

**One-liner:** Removed glass-on-glass stacking from ContentView root, upgraded TuningSelector to glassCard, and grouped string rail pills in GlassEffectContainer for unified refractive compositing.

## What Was Done

Three targeted fixes to correct glass layering architecture per Apple's Liquid Glass guidance against stacking glass on glass:

1. Removed `.modifier(GlassWindowModifier())` from the ContentView ZStack root — the window is already transparent (from Plan 02) so glass components refract against desktop content directly. Applying glass on top of glass components causes double-lensing (muddy, over-darkened artifacts).

2. Replaced `.background(.ultraThinMaterial)` in TuningSelector with `.glassCard(cornerRadius: 16)` — the `GlassCardModifier` handles version gating internally (macOS 26: `.glassEffect(.regular)`, older: `.background(.thinMaterial)`), making this consistent with Phase 4 COR rules.

3. Wrapped the string rail HStack in `GlassEffectContainer` using a version-gated `@ViewBuilder` helper method. On macOS 26+, adjacent glass pills now share one refractive sampling context instead of each independently sampling, preventing double-blur artifacts at pill edges.

## Changes Made

### Source/App/ContentView.swift
- Removed `.modifier(GlassWindowModifier())` from the ZStack root (line 38)
- Added comment explaining the architecture decision
- `GlassWindowModifier` struct retained for documentation/reference

### Source/Views/TuningSelector.swift
- Line 29: `.background(.ultraThinMaterial)` replaced with `.glassCard(cornerRadius: 16)`

### Source/Views/StringRailView.swift
- Extracted `stringRailContent(notes:)` as a private `@ViewBuilder` method
- `ScrollView` body now calls the helper, keeping `.padding(.horizontal, 24)` at the right level
- Helper uses `if #available(macOS 26.0, *)` to wrap `HStack` in `GlassEffectContainer` on macOS 26+
- Fallback `else` branch is the original plain `HStack` (identical behavior on older macOS)

## Verification Results

**Build:** `swift build` — Build complete, zero errors, zero warnings (3.53s)

**Tests:** `swift test` — 173/173 tests passed across 14 suites (0.619s)

No deviations were required. All three changes were straightforward modifications matching the plan exactly.

## Issues Encountered

None. The `GlassEffectContainer` API is available on macOS 26 and the version gating pattern was already established throughout the codebase, making Task 3 a clean addition following the existing pattern.

## Self-Check: PASSED

- Source/App/ContentView.swift: FOUND (no GlassWindowModifier() usage outside struct definition)
- Source/Views/TuningSelector.swift: FOUND (.glassCard(cornerRadius: 16) on line 29)
- Source/Views/StringRailView.swift: FOUND (GlassEffectContainer on line 22)
- Commit 1067167 (Task 1): FOUND
- Commit d0b9121 (Task 2): FOUND
- Commit 8f16338 (Task 3): FOUND
