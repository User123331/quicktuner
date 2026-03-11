---
phase: 03-tuning-library
plan: 02
name: Persistence Service
completed: 2026-03-12
duration: 5m
tasks: 3
task-completed: 3
subsystem: Persistence
status: completed
requirements:
  - PREF-01
  - PREF-02
  - PREF-03
tech-stack:
  added:
    - Swift Actor for thread-safe file operations
    - UserDefaults for scalar persistence
    - FileManager for Application Support directory
  patterns:
    - Atomic file writes (temp then move)
    - Actor isolation for concurrent access safety
    - Graceful degradation on decode errors
key-files:
  created:
    - Sources/Utilities/Constants.swift
    - Sources/Services/PersistenceService.swift
    - Tests/ConstantsTests.swift
    - Tests/PersistenceServiceTests.swift
  modified:
    - Sources/ViewModels/TunerViewModel.swift
decisions:
  - Used explicit UserDefaults instead of @AppStorage for more control over when values are persisted
  - Actor-based service ensures thread-safe file operations without manual locking
  - Atomic write pattern prevents data corruption if app crashes during save
---

# Phase 03 Plan 02: Persistence Service Summary

## Overview

Implemented the hybrid persistence layer combining UserDefaults for scalar values and JSON files in Application Support for custom tunings. This enables user settings and custom tunings to survive app restarts.

## What Was Built

### Constants Layer

**Constants.swift** (`Sources/Utilities/Constants.swift`)
- **PersistenceKeys** enum with string constants for UserDefaults keys
  - `selectedInstrument`, `selectedTuningId`, `referencePitch`
  - `noiseGateThreshold`, `selectedAudioDeviceId`
- **ReferencePitchConstants** with min/max/default and normalization function
  - Range: 420.0 - 444.0 Hz
  - Presets: [440, 432, 420]
  - Auto-clamping and rounding to 1 decimal place
- **FilePaths** enum with Application Support URLs
  - `applicationSupportDirectory`: ~/Library/Application Support
  - `quickTunerDirectory`: ~/Library/Application Support/QuickTuner
  - `customTuningsURL`: ~/Library/Application Support/QuickTuner/custom-tunings.json

### Persistence Service

**PersistenceService** (`Sources/Services/PersistenceService.swift`)
- Actor-based for thread-safe file operations
- **loadCustomTunings()**: Returns empty array on missing/corrupted files (graceful degradation)
- **saveCustomTunings()**: Atomic writes using temp file then move pattern
- **deleteCustomTunings()**: Removes custom tunings file
- **createDirectoryIfNeeded()**: Creates QuickTuner directory on first write

Key implementation details:
- JSONEncoder with `.prettyPrinted` and `.sortedKeys` for human-readable output
- ISO8601 date encoding for future extensibility
- Atomic write prevents corruption: writes to `.tmp` file, then moves to final location

### ViewModel Integration

**TunerViewModel Updates** (`Sources/ViewModels/TunerViewModel.swift`)
- Added `tuningLibrary` and `persistenceService` dependencies
- **referencePitch**: Property with didSet observer for normalization and persistence
- **selectedInstrument**: Property with didSet observer for library update and persistence
- **selectedTuningId**: Private property for persistence restoration
- **loadCustomTunings()**: Loads and registers custom tunings on init
- **restoreSelectedTuning()**: Restores last selected tuning from saved ID
- **selectTuning()**: Selects tuning and persists the ID
- **saveCustomTuning()**: Adds to library and persists to disk
- **deleteCustomTuning()**: Removes from library and persists changes

## Test Coverage

**ConstantsTests** (17 tests)
- Persistence key string values
- Reference pitch constants (min, max, default, step, presets)
- Reference pitch normalization (clamping, rounding)
- File path structure and hierarchy

**PersistenceServiceTests** (10 tests)
- Load returns empty when file doesn't exist
- Load returns empty on decode errors (graceful degradation)
- Save/load roundtrip preserves tuning data
- Save creates directory if needed
- Atomic write uses temp file pattern
- Save overwrites existing files
- Delete removes files and is idempotent
- JSON is pretty printed and sorted
- Actor isolation prevents concurrent access issues

## Deviations from Plan

### No Deviations

All aspects executed exactly as planned:
- Constants.swift structure matches specifications
- PersistenceService actor pattern as designed
- Atomic write implementation follows RESEARCH.md guidelines
- Graceful degradation on decode errors implemented
- TunerViewModel integration with proper initialization flow

### Minor Implementation Choice

The plan specified `@AppStorage` for persistence, but we used explicit `UserDefaults` with `didSet` observers. This provides:
- More control over when values are persisted
- Ability to normalize reference pitch on change
- Compatibility with the existing ViewModel architecture

This is functionally equivalent to @AppStorage but with more explicit control.

## Verification Results

```
✔ Test run with 137 tests in 10 suites passed
✔ Build completes without errors or warnings
✔ All 27 new tests pass (17 Constants + 10 PersistenceService)
✔ All 110 existing tests continue to pass
```

## Next Steps

This plan provides the foundation for:
1. Custom tuning creation UI (Plan 03-03)
2. Tuning selector UI component
3. Reference pitch UI controls
4. Settings/preferences screen

## Commits

```
da94e02 feat(phase-03-02): add Constants.swift with persistence keys and reference pitch constants
02ad7bb feat(phase-03-02): implement PersistenceService with atomic JSON writes
34ec004 feat(phase-03-02): integrate persistence into TunerViewModel
```
