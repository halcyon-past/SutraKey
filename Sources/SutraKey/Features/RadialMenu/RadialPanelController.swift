import AppKit
import SwiftUI

/// Custom hosting view that accepts the first click in non-activating floating panels.
final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

/// Custom non-activating floating panel that stays on top and ignores window key activation.
final class NonActivatingRadialPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

/// Manages the non-activating floating NSPanel for the radial menu under the mouse cursor.
@MainActor
public final class RadialPanelController: NSObject {
    public static let shared = RadialPanelController()

    private var panel: NSPanel?
    private var radialView: RadialMenuView?
    private var centerScreenPoint: CGPoint = .zero
    private var isDisplayed: Bool = false

    public override init() {
        super.init()
    }

    /// Presents the radial pie menu centered at the cursor location, clamped to screen boundaries.
    public func showMenu(
        for url: URL,
        at screenPoint: CGPoint,
        onAction: @escaping (ConversionAction) -> Void
    ) {
        dismiss()

        let panelSize: CGFloat = 340.0
        let margin: CGFloat = 16.0

        // Find the screen containing screenPoint
        let screens = NSScreen.screens
        let targetScreen = screens.first(where: { NSPointInRect(screenPoint, $0.frame) }) ?? NSScreen.main ?? screens.first
        let visible = targetScreen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1470, height: 956)

        // Calculate clamped origin so the panel never exceeds screen boundaries (e.g. at the top URL bar)
        let idealOriginX = screenPoint.x - panelSize / 2.0
        let idealOriginY = screenPoint.y - panelSize / 2.0

        let minX = visible.minX + margin
        let maxX = max(minX, visible.maxX - panelSize - margin)
        let clampedX = min(max(idealOriginX, minX), maxX)

        let minY = visible.minY + margin
        let maxY = max(minY, visible.maxY - panelSize - margin)
        let clampedY = min(max(idealOriginY, minY), maxY)

        let panelRect = NSRect(x: clampedX, y: clampedY, width: panelSize, height: panelSize)
        self.centerScreenPoint = CGPoint(x: clampedX + panelSize / 2.0, y: clampedY + panelSize / 2.0)

        let newPanel = NonActivatingRadialPanel(
            contentRect: panelRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        newPanel.isOpaque = false
        newPanel.backgroundColor = .clear
        newPanel.level = .popUpMenu
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        newPanel.hasShadow = false
        newPanel.ignoresMouseEvents = false
        newPanel.acceptsMouseMovedEvents = true

        let menuView = RadialMenuView(
            url: url,
            onSelectAction: { [weak self] action in
                self?.dismiss()
                onAction(action)
            },
            onCancel: { [weak self] in
                self?.dismiss()
            }
        )

        self.radialView = menuView
        newPanel.contentView = FirstMouseHostingView(rootView: menuView)
        self.panel = newPanel
        self.isDisplayed = true

        newPanel.orderFrontRegardless()
    }

    /// Checks if a global screen point is within the panel's frame.
    public func containsPoint(_ point: CGPoint) -> Bool {
        guard isDisplayed, let panel = panel else { return false }
        return NSPointInRect(point, panel.frame)
    }

    /// Returns the active panel's frame in screen coordinates.
    public var panelFrame: NSRect? {
        panel?.frame
    }

    /// Handles mouse dragged event to update hovered slice.
    public func handleMouseDragged(currentLocation: CGPoint) {
        guard isDisplayed, let view = radialView else { return }
        let delta = CGPoint(
            x: currentLocation.x - centerScreenPoint.x,
            y: currentLocation.y - centerScreenPoint.y
        )
        view.updateHover(cursorDelta: delta)
    }

    /// Handles mouse moved event to update hovered slice.
    public func handleMouseMoved(currentLocation: CGPoint) {
        guard isDisplayed, let view = radialView else { return }
        let delta = CGPoint(
            x: currentLocation.x - centerScreenPoint.x,
            y: currentLocation.y - centerScreenPoint.y
        )
        view.updateHover(cursorDelta: delta)
    }

    /// Handles mouse up event to commit selected slice.
    public func handleMouseUp(currentLocation: CGPoint) {
        guard isDisplayed, let view = radialView else { return }
        let delta = CGPoint(
            x: currentLocation.x - centerScreenPoint.x,
            y: currentLocation.y - centerScreenPoint.y
        )
        view.commitSelection(cursorDelta: delta)
    }

    /// Cleanly dismisses the panel.
    public func dismiss() {
        guard isDisplayed else { return }
        isDisplayed = false
        panel?.orderOut(nil)
        panel = nil
        radialView = nil
    }

    public var isVisible: Bool {
        isDisplayed
    }
}
