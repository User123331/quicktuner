# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-11)

**Core value:** Real-time, sub-cent-accurate pitch detection with a frictionless string-by-string tuning flow that feels like a precision instrument built into the OS.
**Current focus:** Phase 5 — Cleanup, Title Bar, and Liquid Glass

## Current Position

Phase: 5 of 5 (Cleanup, Title Bar, and Liquid Glass)
Plan: 3 complete, awaiting next plan
Status: **Phase 5, Plan 03 complete — Glass architecture cleaned, no glass-on-glass stacking**
Last activity: 2026-03-13 -- Completed 05-03 (remove GlassWindowModifier, TuningSelector glassCard, StringRailView GlassEffectContainer)

Progress: [███░░░░░░░] 30% (Phase 5, 3/? plans)

## Performance Metrics

**Velocity:**
- Total plans completed: 14
- Average duration: 8 minutes
- Total execution time: ~2 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 02-tuner-interface | 5 | 5 | 12 min |
| 03-tuning-library | 5 | 5 | 10 min |
| 04-window-design | 5+GAP+FIX+COR | All | 5 min |

| 05-cleanup-titlebar-glass | 3 | 21 min | 7 min |

*Updated after each plan completion*

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Phase 5-03]: No glass on ContentView root — transparent window backdrop lets glass components refract desktop directly
- [Phase 5-03]: TuningSelector.glassCard(cornerRadius:16) provides version-gated glass consistent with Phase 4 COR
- [Phase 5-03]: GlassEffectContainer groups string rail pills into one refractive sampling context on macOS 26+

- [Phase 5-02]: isOpaque=false + backgroundColor=.clear required for true vibrancy — glass must refract desktop, not window background color
- [Phase 5-02]: Top padding 52pt chosen for traffic light clearance (title bar ~28pt + comfortable spacing)
- [Phase 5-02]: Settings gear at 12pt top padding aligns with standard macOS traffic light vertical zone

- [Phase 5-01]: MainActor.assumeIsolated is the correct fix for actor isolation in NotificationCenter callbacks on queue:.main
- [Phase 5-01]: await not needed when calling synchronous actor methods from a Task that inherits the same actor context
- [Phase 5-01]: Git index cleaned — Sources/ (stale) → Source/ (correct) via git rm --cached

- [Phase 4-COR]: On macOS 26, `.glassEffect()` REPLACES `.background(.material)` — don't combine them
- [Phase 4-COR]: Window does NOT need `isOpaque = false` or `backgroundColor = .clear` for Liquid Glass
- [Phase 4-COR]: Use `.glassEffect(.regular, in: .rect(cornerRadius:))` with shape parameter for proper clipping
- [Phase 4-COR]: Interactive elements use `.glassEffect(.regular.interactive(), in: shape)`
- [Phase 4-COR]: Version-gate all `.glassEffect()` calls with `if #available(macOS 26.0, *)`
- [Phase 4-COR]: Package.swift paths must match actual filesystem (`Source/` not `Sources/`)

- [Phase 4-FIX-01]: Horizontal ScrollView with showsIndicators: false for clean aesthetic
- [Phase 4-FIX-02]: Canvas as root view enables floating needle without container background panel
- [Phase 4-FIX-03]: Opacity 0.4 strikes balance between transparency and readability for ultra-thin liquid glass

- [Phase 4-GAP-03]: Triangle needle with shadow creates depth and precision instrument feel
- [Phase 4-GAP-03]: Multi-layer glow effect (4 rings) creates aura/breathing animation
- [Phase 4-GAP-04]: Settings button uses overlay approach (toolbar not visible with hidden title bar)
- [Phase 4-GAP-02]: .focusEffectDisabled(true) applied at root and button level
- [Phase 4-GAP-01]: Window transparency required for material/vibrancy effects (SUPERSEDED by COR)

- [Phase 4-01]: @MainActor required on WindowManager for NSWindow concurrency safety (Swift 6)
- [Phase 4-01]: NSKeyedArchiver used for frame persistence (not @AppStorage - cannot store NSRect)

### Completed Requirements

- UI-03: Liquid Glass effect using macOS 26 `.glassEffect()` API with proper shape parameters
- UI-02: Focus effects disabled (.focusEffectDisabled) for clean glass aesthetic
- UI-02: Liquid Glass applied to window container, string buttons, settings gear
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
- TUNE-01 through TUNE-09: All tuning requirements

### Pending Todos

- Visual verification: Run the app and confirm Liquid Glass renders correctly

### Blockers/Concerns

- None

## Session Continuity

Last session: 2026-03-13
Stopped at: Phase 5 Plan 03 Complete — Glass architecture cleaned, no glass-on-glass stacking, GlassEffectContainer on string rail
Resume file: Ready for next plan in phase 5

---

## Phase 4 CORRECTION Summary

**Root Causes Fixed:**
1. Package.swift had wrong paths (`Sources` → `Source`)
2. Window was transparent due to `isOpaque = false` + `backgroundColor = .clear`
3. `.glassEffect()` was never applied to ContentView (only material backgrounds)
4. StringPill/StringButton used manual backgrounds instead of glass modifiers
5. GlassStyles combined material + glassEffect (wrong pattern for macOS 26)

**Files Modified:**
- Package.swift (path fix)
- Source/App/ContentView.swift (glass window + circle button modifiers)
- Source/App/AppDelegate.swift (removed transparency overrides)
- Source/Styles/GlassStyles.swift (proper macOS 26 API with version gating)
- Source/Views/StringRailView.swift (glass button on StringButton)
- Source/Views/StringPill.swift (glass button on StringPill)
- Tests/Styles/GlassStylesTests.swift (updated for new modifier types)

**Build Status:** ✅ Passing
**Tests:** ✅ 173/173 passing
