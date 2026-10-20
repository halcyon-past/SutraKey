import AppKit
import SwiftUI

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

    /// Presents the radial pie menu centered exactly at the cursor location.
    public func showMenu(
        for url: URL,
        at screenPoint: CGPoint,
        onAction: @escaping (ConversionAction) -> Void
    ) {
        dismiss()

        self.centerScreenPoint = screenPoint
        let panelSize: CGFloat = 320.0

        let newPanel = NSPanel(
            contentRect: NSRect(
                x: screenPoint.x - panelSize / 2.0,
                y: screenPoint.y - panelSize / 2.0,
                width: panelSize,
                height: panelSize
            ),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        newPanel.isOpaque = false
        newPanel.backgroundColor = NSColor.clear
        newPanel.level = NSWindow.Level.popUpMenu
        newPanel.collectionBehavior = [NSWindow.CollectionBehavior.canJoinAllSpaces, NSWindow.CollectionBehavior.fullScreenAuxiliary]
        newPanel.hasShadow = false
        newPanel.ignoresMouseEvents = false

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
        newPanel.contentView = NSHostingView(rootView: menuView)
        self.panel = newPanel
        self.isDisplayed = true

        newPanel.orderFrontRegardless()
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
