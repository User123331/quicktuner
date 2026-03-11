import AppKit
import Foundation

/// Manages window frame persistence with multi-monitor support
/// Uses NSKeyedArchiver for reliable NSRect encoding (not @AppStorage)
@MainActor
final class WindowManager {
    static let shared = WindowManager()

    private let frameKey = "windowFrame"
    private let screenKey = "windowScreenID"

    // MARK: - Public Methods

    /// Saves the current window position and size to UserDefaults
    func saveWindowPosition(for window: NSWindow) {
        let frame = window.frame

        // Archive frame using NSValue
        let frameValue = NSValue(rect: frame)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: frameValue, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: frameKey)
        }

        // Save screen identifier for multi-monitor support
        if let screen = window.screen {
            let screenID = screen.localizedName + "_" + String(describing: screen.frame.size)
            UserDefaults.standard.set(screenID, forKey: screenKey)
        }
    }

    /// Restores window position from UserDefaults with validation
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

            // Clamp to visible area (account for menu bar, dock)
            savedFrame.origin.x = max(visibleFrame.minX,
                                       min(savedFrame.origin.x,
                                           visibleFrame.maxX - savedFrame.width))
            savedFrame.origin.y = max(visibleFrame.minY,
                                       min(savedFrame.origin.y,
                                           visibleFrame.maxY - savedFrame.height))

            window.setFrame(savedFrame, display: true)
        } else {
            window.setFrame(defaultFrame, display: true)
        }
    }

    /// Validates and adjusts window position if needed (e.g., after screen change)
    func validateWindowPosition(for window: NSWindow) {
        guard let screen = window.screen else {
            // Window not on any screen, restore to default
            let defaultFrame = centerFrame(for: window, on: NSScreen.main)
            window.setFrame(defaultFrame, display: true)
            return
        }

        let visibleFrame = screen.visibleFrame
        var frame = window.frame

        // Check if window is partially or fully off-screen
        let isOffScreen = frame.maxX <= visibleFrame.minX ||
                          frame.minX >= visibleFrame.maxX ||
                          frame.maxY <= visibleFrame.minY ||
                          frame.minY >= visibleFrame.maxY

        if isOffScreen {
            // Clamp to visible area
            frame.origin.x = max(visibleFrame.minX,
                                  min(frame.origin.x,
                                      visibleFrame.maxX - frame.width))
            frame.origin.y = max(visibleFrame.minY,
                                  min(frame.origin.y,
                                      visibleFrame.maxY - frame.height))
            window.setFrame(frame, display: true)
        }
    }

    // MARK: - Private Methods

    /// Creates a centered frame for the window on the specified screen
    private func centerFrame(for window: NSWindow, on screen: NSScreen?) -> NSRect {
        let screen = screen ?? NSScreen.main!
        let screenFrame = screen.visibleFrame

        // Use window's current size or default to 440x600
        let windowSize = CGSize(width: 440, height: 600)

        return NSRect(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2,
            width: windowSize.width,
            height: windowSize.height
        )
    }
}
