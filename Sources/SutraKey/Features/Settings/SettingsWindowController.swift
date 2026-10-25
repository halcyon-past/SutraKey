import AppKit
import SwiftUI

/// Manages the lifecycle of the SutraKey Settings window.
@MainActor
public final class SettingsWindowController: NSObject, NSWindowDelegate {
    public static let shared = SettingsWindowController()

    private var window: NSWindow?

    public override init() {
        super.init()
    }

    /// Displays the Settings window, creating it if needed and bringing it to the front.
    public func showSettings() {
        if let existing = window {
            existing.center()
            existing.makeKeyAndOrderFront(nil)
            existing.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 520),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        win.title = "SutraKey Settings"
        win.contentViewController = hostingController
        win.center()
        win.isReleasedWhenClosed = false
        win.delegate = self

        self.window = win
        win.makeKeyAndOrderFront(nil)
        win.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    public func windowWillClose(_ notification: Notification) {
        // Keeps window reference cached for instant, leak-free reopening
    }
}
