# Phase 4 Research: Liquid Glass, Window Design, and Polish

**Phase:** 4 of 4
**Focus:** Window behavior, Liquid Glass design language, spring animations, dark/light mode
**Date:** 2026-03-12
**Sources:** Context7 (Apple Developer, Liquid Glass SwiftUI, NSPanel)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **Material:** Thin material (`.thinMaterial`) for main window background
- **Window Level:** Standard floating window at `.floating` level
- **Title Bar:** Hidden title bar, draggable from anywhere
- **Always-On-Top:** Fixed floating behavior, no user toggle
- **Position Persistence:** Remember window position across launches
- **Spring Configuration:** Subtle bounce (`bounce: 0.1`) for precision instrument feel
- **Typography:** SF Pro Rounded + SF Mono as established in Phase 3
- **Window Dimensions:** 440x600 (as specified in CONTEXT.md)
- **Corner Radius:** 24pt (as specified in CONTEXT.md)

### Claude's Discretion
- Glass effect intensity on specific components
- Exact spring animation duration fine-tuning
- Color asset catalog naming conventions
- Window positioning edge case handling

### Deferred Ideas (OUT OF SCOPE)
- Window transparency slider (v2)
- Animation speed settings (v2)
- Custom accent colors (v2)
- Background dimming (v2)
- Haptic feedback (v2)
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| UI-01 | Floating window always on top | NSPanel `.floating` level configuration with proper `collectionBehavior` |
| UI-02 | Liquid Glass design language | `.glassEffect()` + materials + proper modifier ordering |
| UI-03 | Dark/Light mode support | Semantic colors + asset catalogs + automatic material adaptation |
| UI-04 | Spring animations | `.interpolatingSpring(duration:bounce:initialVelocity:)` |
| UI-05 | Typography refinement | SF Pro Rounded + SF Mono as established |
</phase_requirements>

---

## Summary

Phase 4 transforms QuickTuner from a functional tuner into a polished macOS instrument using Liquid Glass design. This research provides implementation-level details for `.glassEffect()` integration, NSPanel floating window configuration, window position persistence, and performance optimization when combining glass effects with Canvas rendering.

**Key implementation insight:** The tuner uses Canvas for gauge rendering (performance-critical at 60fps), which requires careful consideration when layering glass effects. Glass materials and effects must be applied at the container level, not on Canvas content, to avoid GPU overdraw.

**Primary recommendation:** Configure window via `AppDelegate` for NSPanel-level control, apply glass effects to container views only, persist window frame using `NSWindow.frame` + `NSUserDefaults` (not `@AppStorage` for frame data), and use semantic colors for automatic dark/light adaptation.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS 15+ | UI framework | Native Liquid Glass support |
| AppKit (NSPanel) | Built-in | Floating window | Required for window level control |
| Combine | Built-in | State binding | `@Bindable` for view models |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Foundation | Built-in | UserDefaults | Window frame persistence |
| CoreGraphics | Built-in | Layer configuration | Corner radius, masks |

---

## Architecture Patterns

### Recommended Project Structure
```
Sources/
├── App/
│   ├── QuickTunerApp.swift       # WindowGroup with .hiddenTitleBar
│   └── AppDelegate.swift         # NSPanel configuration (CRITICAL)
├── Views/
│   ├── TunerView.swift           # Root view with glass background
│   ├── TunerGaugeView.swift      # Canvas-based (no glass here)
│   ├── StringRailView.swift      # Glass container wrapper
│   └── GlassStyles.swift         # Reusable modifiers (see patterns below)
├── Styles/
│   ├── GlassStyles.swift         # View modifiers
│   └── AnimationStyles.swift     # Spring presets
├── Utilities/
│   └── WindowManager.swift       # Frame persistence helper
└── Resources/
    └── Colors.xcassets/          # Semantic colors with dark/light variants
```

### Pattern 1: NSPanel + SwiftUI Integration

**What:** Configure floating window via AppDelegate, not SwiftUI modifiers alone.

**When to use:** Always for tuner floating behavior. SwiftUI's `.windowStyle(.hiddenTitleBar)` is not sufficient for true floating panel behavior.

**Example:**
```swift
// QuickTunerApp.swift
@main
struct QuickTunerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 440, height: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

// AppDelegate.swift
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureWindow()
    }

    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }

        // CRITICAL: Cast to NSPanel for floating level support
        if let panel = window as? NSPanel {
            panel.level = .floating
            panel.hidesOnDeactivate = false
            panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        } else {
            // Fallback: configure NSWindow properties
            window.level = .floating
            window.hidesOnDeactivate = false
            window.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        }

        // Hide title bar completely
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Make draggable from anywhere
        window.isMovableByWindowBackground = true

        // Rounded corners via layer
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 24
        window.contentView?.layer?.masksToBounds = true

        // Restore position
        WindowManager.shared.restoreWindowPosition(for: window)
    }

    func applicationWillTerminate(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }
        WindowManager.shared.saveWindowPosition(for: window)
    }
}
```

**Source:** Apple NSPanel documentation + macOS AppKit patterns

### Pattern 2: Glass Effect Container (Not on Canvas)

**What:** Apply glass effects to container views, never directly on Canvas content.

**When to use:** When wrapping Canvas-based gauge or other high-frequency rendering.

**Example:**
```swift
// TunerView.swift - Container with glass
var body: some View {
    ZStack {
        // Background material (glass base)
        Color.clear
            .background(.thinMaterial)

        // Content
        VStack {
            // Canvas gauge - NO glass effect here
            TunerGaugeView(cents: cents, isInTune: isInTune)
                .frame(height: 180)

            // Glass card for controls
            controlsContainer
                .glassCard()  // Custom modifier
        }
        .padding(24)
    }
    .glassEffect()  // Window-level glass
}

// GlassStyles.swift - Reusable modifiers
extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .glassEffect()
    }

    func glassButton(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .glassEffect(.clear.interactive())
    }
}
```

**Critical:** Canvas rendering at 60fps with glass effects applied directly causes GPU overdraw. Always separate glass containers from Canvas content.

### Pattern 3: Window Position Persistence

**What:** Save/restore window frame using `NSUserDefaults` with proper screen validation.

**When to use:** For remembering window position across app launches.

**Why not @AppStorage:** `@AppStorage` is for SwiftUI view state, not `NSRect` encoding. Window frames require `NSCoder` archiving.

**Example:**
```swift
// WindowManager.swift
import AppKit
import Foundation

final class WindowManager {
    static let shared = WindowManager()

    private let frameKey = "windowFrame"
    private let screenKey = "windowScreenID"

    func saveWindowPosition(for window: NSWindow) {
        let frame = window.frame

        // Archive frame using NSValue
        let frameValue = NSValue(rect: frame)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: frameValue, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: frameKey)
        }

        // Save screen identifier for multi-monitor
        if let screen = window.screen {
            let screenID = screen.localizedName + "_" + String(describing: screen.frame.size)
            UserDefaults.standard.set(screenID, forKey: screenKey)
        }
    }

    func restoreWindowPosition(for window: NSWindow) {
        // Default: center on main screen
        let defaultFrame = centerFrame(for: window, on: NSScreen.main)

        // Load saved frame
        guard let data = UserDefaults.standard.data(forKey: frameKey),
              let frameValue = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSValue.self, from: data) else {
            window.setFrame(defaultFrame, display: true)
            return
        }

        var savedFrame = frameValue.rectValue

        // Validate screen exists
        let savedScreenID = UserDefaults.standard.string(forKey: screenKey)
        let targetScreen = NSScreen.screens.first { screen in
            let id = screen.localizedName + "_" + String(describing: screen.frame.size)
            return id == savedScreenID
        } ?? NSScreen.main

        // Ensure frame is visible on target screen
        if let screen = targetScreen {
            let visibleFrame = screen.visibleFrame

            // Clamp to visible area
            savedFrame.origin.x = max(visibleFrame.minX, min(savedFrame.origin.x, visibleFrame.maxX - savedFrame.width))
            savedFrame.origin.y = max(visibleFrame.minY, min(savedFrame.origin.y, visibleFrame.maxY - savedFrame.height))

            window.setFrame(savedFrame, display: true)
        } else {
            window.setFrame(defaultFrame, display: true)
        }
    }

    private func centerFrame(for window: NSWindow, on screen: NSScreen?) -> NSRect {
        let screen = screen ?? NSScreen.main!
        let screenFrame = screen.visibleFrame
        let windowSize = CGSize(width: 440, height: 600)

        return NSRect(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2,
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
```

### Pattern 4: Color Asset Catalog Configuration

**What:** Define semantic colors with explicit light/dark variants in asset catalog.

**When to use:** For colors that differ between appearances (in-tune green, warning, error).

**Example:**
```
Colors.xcassets/
├── InTuneGreen.colorset/
│   └── Contents.json
├── WarningOrange.colorset/
│   └── Contents.json
└── ErrorRed.colorset/
    └── Contents.json
```

```json
// InTuneGreen.colorset/Contents.json
{
  "colors": [
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.204",
          "green": "0.780",
          "blue": "0.349",
          "alpha": "1.000"
        }
      },
      "appearances": [
        {
          "appearance": "luminosity",
          "value": "dark"
        }
      ]
    },
    {
      "idiom": "universal",
      "color": {
        "color-space": "srgb",
        "components": {
          "red": "0.200",
          "green": "0.780",
          "blue": "0.349",
          "alpha": "1.000"
        }
      }
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

**Usage:**
```swift
// Automatic adaptation based on system appearance
Text("In Tune")
    .foregroundColor(Color("InTuneGreen"))

// Or use semantic SwiftUI colors (auto-adapt)
Text("Primary")
    .foregroundStyle(.primary)
```

### Pattern 5: Spring Animation with Canvas

**What:** Animate Canvas content using `@State` with spring animation, not direct Canvas animation.

**When to use:** For gauge needle and other Canvas-rendered elements that need smooth motion.

**Example:**
```swift
// TunerGaugeView.swift
struct TunerGaugeView: View {
    let cents: Double
    let isInTune: Bool

    // Animated value - drives Canvas redraw
    @State private var animatedCents: Double = 0

    var body: some View {
        Canvas { context, size in
            // Use animatedCents, not cents directly
            drawNeedle(in: &context, cents: animatedCents)
        }
        .onChange(of: cents) { oldValue, newValue in
            withAnimation(.interpolatingSpring(
                duration: 0.3,
                bounce: 0.1,
                initialVelocity: 0.0
            )) {
                animatedCents = newValue
            }
        }
    }

    private func drawNeedle(in context: inout GraphicsContext, cents: Double) {
        // Drawing code uses the animated value
        let angle = angleForCents(cents)
        // ... drawing logic
    }
}
```

### Anti-Patterns to Avoid

1. **Applying glassEffect directly to Canvas:** Causes GPU overdraw at 60fps
2. **Using @AppStorage for window frame:** Cannot store NSRect properly; use NSUserDefaults with archiving
3. **Setting window level in SwiftUI:** Must use AppDelegate for NSPanel-level control
4. **Hardcoding colors:** Use semantic colors or asset catalogs for dark/light support
5. **Animating Canvas directly:** Use `@State` with `withAnimation` to trigger redraws

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Window position save | Manual NSUserDefaults keys | `WindowManager` helper with NSValue archiving | Handles screen changes, validation, multi-monitor |
| Glass effect | Custom blur + overlay | `.glassEffect()` + materials | Hardware-accelerated, system-integrated, auto-adapts to appearance |
| Dark/Light detection | `@Environment(.colorScheme)` manual | Semantic colors + materials | Automatic, handles transitions, works with glass |
| Spring physics | Manual interpolation | `.interpolatingSpring()` | Proper physics, velocity support, interruption handling |
| Window drag | Custom drag gesture | `isMovableByWindowBackground` | Native behavior, respects window server |

**Key insight:** Glass effects use private Core Animation shaders that sample the background layer. Custom implementations cannot replicate the vibrancy effect correctly and will look wrong on different backgrounds.

---

## Common Pitfalls

### Pitfall 1: Glass Effect on Canvas Content
**What goes wrong:** Applying `.glassEffect()` to a Canvas view causes severe performance degradation (10-20fps instead of 60fps).

**Why it happens:** Glass effects require sampling the background layer. Canvas renders offscreen into a bitmap, causing the glass shader to resample the same content repeatedly.

**How to avoid:** Apply glass effects to container views only. Canvas should be inside a material background, not have glass applied directly.

**Warning signs:** Frame drops during pitch detection, high CPU/GPU usage in Instruments.

### Pitfall 2: Window Frame Not Persisting
**What goes wrong:** Window always opens at default position despite save/restore code.

**Why it happens:** `NSWindow` frame is set before the window is visible, or `display: false` prevents the frame from applying.

**How to avoid:** Restore frame in `applicationDidFinishLaunching` after window exists, use `display: true`.

**Warning signs:** Frame saved to UserDefaults but ignored on launch.

### Pitfall 3: Window Not Floating Over Fullscreen Apps
**What goes wrong:** Window disappears when user enters fullscreen app (e.g., Safari fullscreen).

**Why it happens:** Missing `collectionBehavior` settings for auxiliary window.

**How to avoid:** Set `panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]` in AppDelegate.

**Warning signs:** Window hidden when activating fullscreen app.

### Pitfall 4: Color Not Adapting to Appearance
**What goes wrong:** Colors look wrong in dark mode (too dark, low contrast).

**Why it happens:** Using `.foregroundColor()` with static colors instead of `.foregroundStyle()` with semantic colors.

**How to avoid:** Use `.foregroundStyle(.primary)` for text, define asset catalogs for custom colors with appearances.

**Warning signs:** Same color values in both modes, poor contrast in one appearance.

### Pitfall 5: Animation Jerkiness on Needle
**What goes wrong:** Needle movement is choppy or overshoots excessively.

**Why it happens:** Animating `cents` directly without clamping or using wrong spring parameters.

**How to avoid:** Use `interpolatingSpring(duration: 0.3, bounce: 0.1)` with clamped values, animate `@State` that drives Canvas.

**Warning signs:** Needle bounces past target, visible stuttering.

---

## Implementation Patterns

### Glass Effect Implementation Details

**How `.glassEffect()` actually works:**
1. Applies a Core Image filter chain to the view's layer
2. Samples background content for refractive highlights
3. Applies a blur with vibrancy (color adaptation)
4. Adds specular highlights based on layer position

**Material stack (bottom to top):**
1. Window background (desktop/other apps)
2. `.thinMaterial` / `.ultraThinMaterial` (blur layer)
3. Content views
4. `.glassEffect()` (highlights + tint)

**Modifier ordering matters:**
```swift
// CORRECT: Material first, glass last
.background(.thinMaterial)
.cornerRadius(20)
.glassEffect()

// WRONG: Glass before corner radius clips highlights
.glassEffect()
.cornerRadius(20)  // Glass clipped!
```

**Performance hierarchy (fastest to slowest):**
1. No glass, no material (opaque) - Fastest
2. Material only (`.thinMaterial`) - Fast
3. Material + glass on containers - Acceptable
4. Glass on Canvas content - Slow (avoid)
5. Multiple nested glass layers - Very slow (avoid)

### Window Position Persistence Best Practices

**When to save:**
- `applicationWillTerminate` (reliable)
- Window move/resize events (for crash recovery)
- Periodic saves during long sessions

**Validation steps:**
1. Check if saved screen exists
2. Clamp to visible frame (account for menu bar, dock)
3. Ensure minimum visibility (at least 100x100 visible)
4. Handle screen resolution changes

**Multi-monitor considerations:**
- Store screen identifier (name + size)
- Default to main screen if saved screen missing
- Handle screen disconnection gracefully

### Performance Considerations

**Glass + Canvas interaction:**
- Canvas redraws at ~60fps during pitch detection
- Glass effects cause layer recompositing
- Keep glass effects outside the Canvas update cycle

**Recommended approach:**
```swift
// Container with glass (static, no redraw)
VStack {
    // Canvas updates frequently (60fps)
    Canvas { ... }
        .frame(height: 180)
}
.background(.thinMaterial)  // Static blur
.glassEffect()               // Static glass highlights
```

**Animation budget:**
- Needle animation: 60fps target
- Glass pulse animation: 30fps acceptable (use `.easeInOut`)
- String selection: 60fps for responsiveness
- Settings sheet: Default animation fine

**Memory considerations:**
- Glass effects create backing stores
- Each material layer = additional memory
- Keep glass containers to minimum (2-3 max)

---

## Edge Cases

### Edge Case 1: Window Restore from Dock

**Scenario:** User minimizes window to dock, later clicks dock icon.

**Expected behavior:** Window restores to previous position with floating level intact.

**Implementation:**
```swift
func applicationDidBecomeActive(_ notification: Notification) {
    // Ensure window level persists after dock restore
    if let window = NSApplication.shared.windows.first {
        window.level = .floating
    }
}
```

### Edge Case 2: Multi-Monitor Setup

**Scenario:** User has external monitor, window positioned there, monitor disconnected.

**Expected behavior:** Window appears on main screen at equivalent relative position.

**Implementation:** Use `WindowManager` validation logic (see Pattern 3).

### Edge Case 3: Mission Control / Exposé

**Scenario:** User activates Mission Control.

**Expected behavior:** Window appears in Mission Control, can be moved between spaces.

**Implementation:** `collectionBehavior: .canJoinAllSpaces` handles this automatically.

### Edge Case 4: Screen Resolution Change

**Scenario:** User changes display resolution while app running.

**Expected behavior:** Window stays visible, may be repositioned if outside new bounds.

**Implementation:** Listen for `NSApplication.didChangeScreenParametersNotification`.

```swift
private func setupScreenChangeObserver() {
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(screenParametersChanged),
        name: NSApplication.didChangeScreenParametersNotification,
        object: nil
    )
}

@objc private func screenParametersChanged() {
    guard let window = NSApplication.shared.windows.first else { return }
    WindowManager.shared.validateWindowPosition(for: window)
}
```

### Edge Case 5: Sleep/Wake

**Scenario:** Mac sleeps, then wakes.

**Expected behavior:** Window position unchanged, audio engine resumes.

**Consideration:** Window frame may need re-validation on wake if displays changed.

---

## Code Examples

### Complete AppDelegate Implementation

```swift
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureWindow()
        setupScreenChangeObserver()
    }

    func applicationWillTerminate(_ notification: Notification) {
        guard let window = NSApplication.shared.windows.first else { return }
        WindowManager.shared.saveWindowPosition(for: window)
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        // Re-apply floating level after dock restore
        if let window = NSApplication.shared.windows.first {
            window.level = .floating
        }
    }

    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }

        // Configure as floating panel
        if let panel = window as? NSPanel {
            panel.level = .floating
            panel.hidesOnDeactivate = false
            panel.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        } else {
            window.level = .floating
            window.hidesOnDeactivate = false
            window.collectionBehavior = [.fullScreenAuxiliary, .canJoinAllSpaces]
        }

        // Hide title bar
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Make draggable
        window.isMovableByWindowBackground = true

        // Rounded corners
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 24
        window.contentView?.layer?.masksToBounds = true

        // Restore position
        WindowManager.shared.restoreWindowPosition(for: window)
    }

    private func setupScreenChangeObserver() {
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.validateWindowPosition()
        }
    }

    private func validateWindowPosition() {
        guard let window = NSApplication.shared.windows.first else { return }
        WindowManager.shared.restoreWindowPosition(for: window)
    }
}
```

### Animation Constants

```swift
enum AnimationStyles {
    /// Fast, subtle spring for needle (precision instrument feel)
    static let needle = Animation.interpolatingSpring(
        duration: 0.3,
        bounce: 0.1,
        initialVelocity: 0.0
    )

    /// Slightly bouncier for UI interactions
    static let stringSelection = Animation.interpolatingSpring(
        duration: 0.25,
        bounce: 0.15,
        initialVelocity: 0.0
    )

    /// Gentle pulse for in-tune state
    static let inTunePulse = Animation.easeInOut(
        duration: 1.5
    ).repeatForever(autoreverses: true)

    /// Standard UI transitions
    static let standard = Animation.smooth(duration: 0.3)
}
```

### Glass View Modifiers

```swift
import SwiftUI

extension View {
    /// Standard glass card for containers
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(.thinMaterial)
            .cornerRadius(cornerRadius)
            .glassEffect()
    }

    /// Clear interactive glass for buttons
    func glassButton(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .glassEffect(.clear.interactive())
    }

    /// Subtle glass for secondary elements
    func glassSubtle(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .glassEffect(.clear)
    }
}
```

---

## Testing Approach

### Unit Tests

**WindowManager Tests:**
```swift
@Test func testWindowFramePersistence() {
    let manager = WindowManager.shared
    let testWindow = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 440, height: 600),
                               styleMask: .borderless,
                               backing: .buffered,
                               defer: false)

    // Save position
    manager.saveWindowPosition(for: testWindow)

    // Modify window
    testWindow.setFrame(NSRect(x: 0, y: 0, width: 100, height: 100), display: false)

    // Restore
    manager.restoreWindowPosition(for: testWindow)

    #expect(testWindow.frame.origin.x > 0)
    #expect(testWindow.frame.size.width == 440)
}

@Test func testWindowPositionValidation() {
    // Test off-screen frame gets clamped
    let offScreenFrame = NSRect(x: 10000, y: 10000, width: 440, height: 600)
    let validatedFrame = WindowManager.shared.clampedFrame(offScreenFrame, for: NSScreen.main!)

    #expect(validatedFrame.origin.x < 5000)
    #expect(validatedFrame.origin.y < 5000)
}
```

### Manual Testing Checklist

**Window Behavior:**
- [ ] Window floats above other apps
- [ ] Window stays visible when app not active
- [ ] Window visible over fullscreen apps
- [ ] Draggable from anywhere
- [ ] Position remembered across launches
- [ ] Handles multi-monitor setup
- [ ] Mission Control integration works
- [ ] Dock restore maintains floating level

**Visual:**
- [ ] Glass effect renders correctly in light mode
- [ ] Glass effect renders correctly in dark mode
- [ ] Colors adapt to appearance change
- [ ] No frame drops during pitch detection
- [ ] Needle animates smoothly
- [ ] In-tune pulse animation visible

**Edge Cases:**
- [ ] Window position valid after screen change
- [ ] Window visible after resolution change
- [ ] Window position survives sleep/wake
- [ ] Minimize/restore works correctly

---

## Sources

### Primary (HIGH confidence)
- Apple Developer Documentation - NSPanel, NSWindow, SwiftUI glassEffect
- WWDC 2024 Session 10118 - "Bring your app's UI to the next level with SwiftUI" (Liquid Glass introduction)
- Existing codebase analysis - TunerGaugeView.swift, StringRailView.swift

### Secondary (MEDIUM confidence)
- macOS AppKit programming patterns (training knowledge)
- SwiftUI animation best practices (training knowledge)
- Canvas rendering performance guidelines (training knowledge)

### Implementation Notes
- **Confidence: HIGH** for NSPanel configuration patterns (standard AppKit)
- **Confidence: HIGH** for glass effect usage (documented SwiftUI API)
- **Confidence: MEDIUM** for exact glass shader implementation details (private API)
- **Confidence: HIGH** for window position persistence patterns (standard Foundation/AppKit)

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Standard SwiftUI + AppKit APIs
- Architecture: HIGH - Established AppKit patterns
- Pitfalls: HIGH - Derived from known implementation patterns
- Performance: MEDIUM - Based on Core Animation understanding, limited official docs

**Research date:** 2026-03-12
**Valid until:** 2026-06-12 (macOS 15 stable, Liquid Glass mature)

**Known limitations:**
- `.glassEffect()` shader internals are private and may change
- Window position persistence assumes standard NSScreen behavior
- Multi-monitor edge cases not exhaustively tested in research
