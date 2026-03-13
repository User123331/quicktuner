import Cocoa
import SwiftUI

/// AppDelegate for configuring the window as a floating panel
/// Handles window level, title bar, drag behavior, and position persistence
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowObserver: NSObjectProtocol?

    // MARK: - NSApplicationDelegate

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
        // Without this, window may lose floating behavior
        guard let window = NSApplication.shared.windows.first else { return }
        window.level = .floating
    }

    // MARK: - Private Methods

    /// Configures the window as a floating panel with hidden title bar
    private func configureWindow() {
        guard let window = NSApplication.shared.windows.first else { return }

        // Configure as floating panel
        // Cast to NSPanel if possible for additional panel-specific features
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

        // Apply rounded corners via layer
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 24
        window.contentView?.layer?.masksToBounds = true

        // Restore position from previous session
        WindowManager.shared.restoreWindowPosition(for: window)
    }

    /// Sets up observer for screen parameter changes (resolution, monitor changes)
    private func setupScreenChangeObserver() {
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.validateWindowPosition()
            }
        }
    }

    /// Validates window position after screen changes
    @objc private func validateWindowPosition() {
        guard let window = NSApplication.shared.windows.first else { return }
        WindowManager.shared.validateWindowPosition(for: window)
    }
}
