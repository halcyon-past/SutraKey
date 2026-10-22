import AppKit
import ApplicationServices
import Foundation
import os

/// Monitors global mouse and keyboard events to detect exclusive Shift-drag text/URL selections.
@MainActor
public final class ShiftSelectionMonitor: NSObject {
    public static let shared = ShiftSelectionMonitor()

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isDraggingWithShift: Bool = false
    private var dragStartLocation: CGPoint?
    private var lastShiftPressTime: TimeInterval = 0

    public override init() {
        super.init()
    }

    /// Starts monitoring mouse and keyboard events.
    public func startMonitoring() {
        guard globalMonitor == nil else { return }

        let eventMask: NSEvent.EventTypeMask = [
            .leftMouseDown,
            .leftMouseDragged,
            .leftMouseUp,
            .flagsChanged,
            .keyDown
        ]

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleEvent(event)
            }
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.handleEvent(event)
            }
            return event
        }

        Logger.events.info("ShiftSelectionMonitor initialized global event tap listener.")
    }

    /// Stops event tap monitoring.
    public func stopMonitoring() {
        if let gMon = globalMonitor {
            NSEvent.removeMonitor(gMon)
            globalMonitor = nil
        }
        if let lMon = localMonitor {
            NSEvent.removeMonitor(lMon)
            localMonitor = nil
        }
    }

    // MARK: - Event Dispatcher

    private func handleEvent(_ event: NSEvent) {
        switch event.type {
        case .flagsChanged:
            handleFlagsChanged(event)
        case .leftMouseDown:
            handleLeftMouseDown(event)
        case .leftMouseDragged:
            handleLeftMouseDragged(event)
        case .leftMouseUp:
            handleLeftMouseUp(event)
        case .keyDown:
            handleKeyDown(event)
        default:
            break
        }
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        guard PreferencesManager.shared.shortcutsEnabled else {
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        // Strict Exclusivity Guard:
        // If another modifier is pressed while radial menu is open, dismiss immediately.
        if ModifierExclusivityValidator.hasConflictingModifiers(flags: event.modifierFlags) {
            if RadialPanelController.shared.isVisible {
                Logger.events.info("Conflicting modifier detected during open radial menu. Dismissing immediately.")
                RadialPanelController.shared.dismiss()
            }
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        // Double-Tap Shift Detection:
        let isShiftPressed = event.modifierFlags.contains(.shift)
        if isShiftPressed && ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) {
            let now = ProcessInfo.processInfo.systemUptime
            if now - lastShiftPressTime < 0.35 {
                Logger.events.info("Double-tap Shift detected! Summoning radial menu under cursor.")
                lastShiftPressTime = 0
                attemptRadialTrigger(at: NSEvent.mouseLocation)
                return
            }
            lastShiftPressTime = now
        }
    }

    private func handleKeyDown(_ event: NSEvent) {
        // Esc key cancels radial menu cleanly
        if event.keyCode == 53 { // 53 = Escape
            if RadialPanelController.shared.isVisible {
                Logger.events.info("Escape key pressed. Dismissing radial menu.")
                RadialPanelController.shared.dismiss()
            }
            return
        }

        // Cmd + Shift + 0 (or Option + Shift + 0) shortcut toggle fallback
        if event.keyCode == 29 { // 29 = '0' (kVK_ANSI_0)
            let flags = event.modifierFlags
            if flags.contains(.shift) && (flags.contains(.command) || flags.contains(.option)) {
                Logger.events.info("Toggle shortcuts hotkey detected via event monitor. Toggling state...")
                PreferencesManager.shared.toggleShortcuts()
                return
            }
        }

        guard PreferencesManager.shared.shortcutsEnabled else { return }

        // Secondary global hotkey listener for Cmd + Shift + S
        if event.keyCode == 1 { // 1 = 'S' (kVK_ANSI_S)
            let flags = event.modifierFlags
            if flags.contains(.command) && flags.contains(.shift) {
                Logger.events.info("Cmd+Shift+S hotkey detected via event monitor. Invoking trigger...")
                attemptRadialTrigger(at: NSEvent.mouseLocation, allowClipboardFallback: true)
            }
        }
    }

    private func handleLeftMouseDown(_ event: NSEvent) {
        // If radial menu is currently open:
        if RadialPanelController.shared.isVisible {
            let mouseLoc = NSEvent.mouseLocation
            if RadialPanelController.shared.containsPoint(mouseLoc) {
                // User clicked inside the radial menu!
                // Do NOT dismiss - let the button / gesture process the selection!
                return
            } else {
                // User clicked outside the menu to dismiss it.
                RadialPanelController.shared.dismiss()
                isDraggingWithShift = false
                dragStartLocation = nil
                return
            }
        }

        guard PreferencesManager.shared.shortcutsEnabled else {
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        // Detect if user initiates click/drag while holding ONLY Shift
        let isShiftDown = ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) ||
                          ModifierExclusivityValidator.isShiftOnly(flags: NSEvent.modifierFlags)

        if isShiftDown {
            isDraggingWithShift = true
            dragStartLocation = NSEvent.mouseLocation
            Logger.events.info("Shift + mouse down initiated at (\(NSEvent.mouseLocation.x, privacy: .public), \(NSEvent.mouseLocation.y, privacy: .public))")
        } else {
            isDraggingWithShift = false
            dragStartLocation = nil
        }
    }

    private func handleLeftMouseDragged(_ event: NSEvent) {
        guard PreferencesManager.shared.shortcutsEnabled else {
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        // If Shift is pressed while dragging, register as active Shift selection
        if !isDraggingWithShift {
            let isShiftDown = ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) ||
                              ModifierExclusivityValidator.isShiftOnly(flags: NSEvent.modifierFlags)
            if isShiftDown {
                isDraggingWithShift = true
            }
        }
    }

    private func handleLeftMouseUp(_ event: NSEvent) {
        let currentLocation = NSEvent.mouseLocation

        // Case A: Radial menu is already active
        if RadialPanelController.shared.isVisible {
            // Keep the menu open; do not dismiss on mouse up.
            // Menu remains accessible until the user clicks a slice, clicks cancel, or clicks outside.
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        guard PreferencesManager.shared.shortcutsEnabled else {
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        let isShiftDown = ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) ||
                          ModifierExclusivityValidator.isShiftOnly(flags: NSEvent.modifierFlags)

        // Case B: User initiated selection with Shift held down, or released mouse while holding Shift
        if isDraggingWithShift || isShiftDown {
            isDraggingWithShift = false
            dragStartLocation = nil

            Logger.events.info("Shift selection finished at (\(currentLocation.x, privacy: .public), \(currentLocation.y, privacy: .public)). Attempting radial menu trigger...")

            // Small 80ms delay to allow macOS window server to finalize text selection highlight
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                self?.attemptRadialTrigger(at: currentLocation, allowClipboardFallback: false)
            }
        } else {
            isDraggingWithShift = false
            dragStartLocation = nil
        }
    }

    /// Attempts to extract URL from selection/clipboard and summon the radial menu.
    public func attemptRadialTrigger(at screenPoint: CGPoint, allowClipboardFallback: Bool = false) {
        guard PreferencesManager.shared.shortcutsEnabled else {
            Logger.events.info("Shortcuts disabled by user preference. Skipping radial trigger.")
            return
        }

        Logger.events.info("Attempting radial trigger at (\(screenPoint.x, privacy: .public), \(screenPoint.y, privacy: .public)) [allowClipboard: \(allowClipboardFallback)]...")

        guard let url = TextSelectionExtractor.extractSelectedURL(allowClipboardFallback: allowClipboardFallback) else {
            Logger.events.warning("No valid URL found in selection or clipboard [allowClipboardFallback: \(allowClipboardFallback)].")

            let isTrusted = AXIsProcessTrusted()
            let frontAppName = NSWorkspace.shared.frontmostApplication?.localizedName ?? "this application"

            if !isTrusted {
                SutraToastController.shared.showNotice(
                    title: "Accessibility Required",
                    message: "To capture links across \(frontAppName) and other apps, enable SutraKey in System Settings > Accessibility.",
                    systemImage: "hand.raised.fill",
                    actionTitle: "Open Settings",
                    action: {
                        let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
                        _ = AXIsProcessTrustedWithOptions(options)
                        if let prefURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                            NSWorkspace.shared.open(prefURL)
                        }
                    }
                )
            } else if allowClipboardFallback {
                // Triggered via shortcut (Cmd+Shift+S)
                SutraToastController.shared.showNotice(
                    title: "No URL Found",
                    message: "Highlight a URL or copy one to your clipboard (⌘C), then press ⌘⇧S.",
                    systemImage: "link.badge.plus"
                )
            } else {
                // Triggered via Shift + Drag selection
                SutraToastController.shared.showNotice(
                    title: "No URL Selected",
                    message: "Highlight a valid URL (YouTube, Instagram, or media link) with Shift held.",
                    systemImage: "cursorarrow.and.square.on.square.dashed"
                )
            }
            return
        }

        Logger.events.info("Summoning radial menu for URL: \(url.absoluteString)")

        RadialPanelController.shared.showMenu(for: url, at: screenPoint) { action in
            Task {
                await ConversionTaskActor.shared.enqueueJob(url: url, action: action)
            }
        }
    }
}
