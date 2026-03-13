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

        // .fullSizeContentView makes contentView fill the ENTIRE window frame
        // including the title bar area. Without this, contentView starts below
        // the title bar and no glass approach can cover the gap.
        window.styleMask.insert(.fullSizeContentView)

        // Transparent title bar — traffic lights remain visible
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.titlebarSeparatorStyle = .none
        // Traffic lights (close/minimize/zoom) are visible by default — do NOT hide them

        // Enable true vibrancy — glass refracts against desktop content
        window.isOpaque = false
        window.backgroundColor = .clear

        // Make draggable from anywhere
        window.isMovableByWindowBackground = true

        // Wrap contentView in an NSVisualEffectView that covers the full window
        // including the title bar area. Now that .fullSizeContentView is set,
        // contentView.bounds covers the entire window frame — no frame math needed.
        if let contentView = window.contentView {
            let visualEffect = NSVisualEffectView()
            visualEffect.material = .hudWindow
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active
            // No cornerRadius or masksToBounds — the window chrome handles the shape.
            // Adding a clip here creates a hard material boundary line at the arc end.
            visualEffect.autoresizingMask = [.width, .height]

            window.contentView = visualEffect
            visualEffect.addSubview(contentView)
            contentView.frame = visualEffect.bounds
            contentView.autoresizingMask = [.width, .height]
        }

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
