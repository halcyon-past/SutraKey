import AppKit
import SwiftUI

/// Custom hosting view with full mouse tracking area and first-mouse clickability.
final class RadialHostingView<Content: View>: NSHostingView<Content> {
    var onMouseMove: ((CGPoint) -> Void)?
    var onMouseClick: ((CGPoint) -> Void)?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeAlways, .inVisibleRect, .mouseEnteredAndExited],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
    }

    override func mouseMoved(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        onMouseMove?(loc)
    }

    override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        onMouseClick?(loc)
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
    private var menuState: RadialMenuState?
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

        let state = RadialMenuState()
        self.menuState = state

        let menuView = RadialMenuView(
            state: state,
            url: url,
            onSelectAction: { [weak self] action in
                self?.dismiss()
                onAction(action)
            },
            onCancel: { [weak self] in
                self?.dismiss()
            }
        )

        let hostingView = RadialHostingView(rootView: menuView)
        hostingView.onMouseMove = { [weak state] loc in
            guard let state = state else { return }
            let center = CGPoint(x: panelSize / 2.0, y: panelSize / 2.0)
            let dx = Double(loc.x - center.x)
            let dy = Double(loc.y - center.y) // In NSView, Y increases upwards
            let dist = hypot(dx, dy)

            if dist < RadialGeometryMath.deadZoneRadius {
                if !state.isCenterHovered {
                    state.isCenterHovered = true
                    state.hoveredAction = nil
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                }
            } else if dist <= 148.0 {
                state.isCenterHovered = false
                let newAction = RadialGeometryMath.action(forOffsetDX: dx, dy: dy)
                if newAction != state.hoveredAction {
                    state.hoveredAction = newAction
                    if newAction != nil {
                        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                    }
                }
            } else {
                state.isCenterHovered = false
                state.hoveredAction = nil
            }
        }

        hostingView.onMouseClick = { [weak self] loc in
            guard let self = self else { return }
            let center = CGPoint(x: panelSize / 2.0, y: panelSize / 2.0)
            let dx = Double(loc.x - center.x)
            let dy = Double(loc.y - center.y)
            let dist = hypot(dx, dy)

            if dist < RadialGeometryMath.deadZoneRadius {
                // Clicked Center Cancel Hub
                self.dismiss()
            } else if dist <= 148.0 {
                if let action = RadialGeometryMath.action(forOffsetDX: dx, dy: dy) {
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                    self.dismiss()
                    onAction(action)
                } else {
                    self.dismiss()
                }
            } else {
                // Clicked outside active pie disc
                self.dismiss()
            }
        }

        newPanel.contentView = hostingView
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

    /// Cleanly dismisses the panel.
    public func dismiss() {
        guard isDisplayed else { return }
        isDisplayed = false
        panel?.orderOut(nil)
        panel = nil
        menuState = nil
    }

    public var isVisible: Bool {
        isDisplayed
    }
}
