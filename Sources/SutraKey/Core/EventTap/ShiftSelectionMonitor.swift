import AppKit
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
        // Strict Exclusivity Guard:
        // If another modifier is pressed while radial menu is open, dismiss immediately.
        if ModifierExclusivityValidator.hasConflictingModifiers(flags: event.modifierFlags) {
            if RadialPanelController.shared.isVisible {
                Logger.events.info("Conflicting modifier detected during open radial menu. Dismissing immediately.")
                RadialPanelController.shared.dismiss()
            }
            isDraggingWithShift = false
            dragStartLocation = nil
        }
    }

    private func handleKeyDown(_ event: NSEvent) {
        // Esc key cancels radial menu cleanly
        if event.keyCode == 53 { // 53 = Escape
            if RadialPanelController.shared.isVisible {
                Logger.events.info("Escape key pressed. Dismissing radial menu.")
                RadialPanelController.shared.dismiss()
            }
        }
    }

    private func handleLeftMouseDown(_ event: NSEvent) {
        if ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) {
            isDraggingWithShift = true
            dragStartLocation = NSEvent.mouseLocation
        } else {
            isDraggingWithShift = false
            dragStartLocation = nil
            if RadialPanelController.shared.isVisible {
                RadialPanelController.shared.dismiss()
            }
        }
    }

    private func handleLeftMouseDragged(_ event: NSEvent) {
        let currentLocation = NSEvent.mouseLocation
        if RadialPanelController.shared.isVisible {
            RadialPanelController.shared.handleMouseDragged(currentLocation: currentLocation)
        }
    }

    private func handleLeftMouseUp(_ event: NSEvent) {
        let currentLocation = NSEvent.mouseLocation

        // Case A: Radial menu is already active -> commit or cancel selection
        if RadialPanelController.shared.isVisible {
            RadialPanelController.shared.handleMouseUp(currentLocation: currentLocation)
            isDraggingWithShift = false
            dragStartLocation = nil
            return
        }

        // Case B: User was holding Shift during selection or click
        if isDraggingWithShift && ModifierExclusivityValidator.isShiftOnly(flags: event.modifierFlags) {
            isDraggingWithShift = false
            dragStartLocation = nil

            // Small delay to allow OS selection state to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.attemptRadialTrigger(at: currentLocation)
            }
        } else {
            isDraggingWithShift = false
            dragStartLocation = nil
        }
    }

    private func attemptRadialTrigger(at screenPoint: CGPoint) {
        // Extract selected URL
        guard let url = TextSelectionExtractor.extractSelectedURL() else {
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
