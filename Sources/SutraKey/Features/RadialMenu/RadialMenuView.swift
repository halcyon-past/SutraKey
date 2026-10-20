import AppKit
import SwiftUI

/// Fluid SwiftUI radial pie menu rendered under the mouse cursor.
public struct RadialMenuView: View {
    public let url: URL
    public let onSelectAction: (ConversionAction) -> Void
    public let onCancel: () -> Void

    @State private var hoveredAction: ConversionAction?
    @State private var cursorDistance: Double = 0.0
    @State private var appeared: Bool = false

    private let menuRadius: CGFloat = 140.0
    private let innerRadius: CGFloat = 38.0

    public init(
        url: URL,
        onSelectAction: @escaping (ConversionAction) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.url = url
        self.onSelectAction = onSelectAction
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            // Background blur disc
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: menuRadius * 2, height: menuRadius * 2)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 24, x: 0, y: 12)

            // 5 Radial Slices
            ForEach(ConversionAction.allCases) { action in
                sliceView(for: action)
            }

            // Center Dead-Zone (< 28pt) Hub
            centerHubView
        }
        .frame(width: menuRadius * 2 + 40, height: menuRadius * 2 + 40)
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: appeared)
        .onAppear {
            appeared = true
        }
    }

    // MARK: - Slices

    @ViewBuilder
    private func sliceView(for action: ConversionAction) -> some View {
        let isHovered = hoveredAction == action
        let centerAngle = RadialGeometryMath.centerAngle(for: action)
        let radians = centerAngle * .pi / 180.0
        let iconRadius: CGFloat = (innerRadius + menuRadius) / 2.0

        let posX = iconRadius * cos(radians)
        let posY = iconRadius * sin(radians)

        ZStack {
            VStack(spacing: 4) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: isHovered ? 24 : 18, weight: .semibold))
                    .foregroundColor(isHovered ? action.accentColor : .white.opacity(0.85))

                Text(action.shortBadge)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(isHovered ? .white : .white.opacity(0.7))
            }
            .offset(x: posX, y: -posY) // Flip Y for macOS coordinate mapping
            .scaleEffect(isHovered ? 1.15 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.68), value: isHovered)
        }
    }

    // MARK: - Center Hub

    private var centerHubView: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.12, opacity: 0.95))
                .frame(width: RadialGeometryMath.deadZoneRadius * 2, height: RadialGeometryMath.deadZoneRadius * 2)
                .overlay(
                    Circle()
                        .stroke(
                            hoveredAction != nil ? hoveredAction!.accentColor.opacity(0.8) : Color.white.opacity(0.2),
                            lineWidth: 1.5
                        )
                )

            if let active = hoveredAction {
                Image(systemName: active.sfSymbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(active.accentColor)
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Subtle Sutra thread knot indicator
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.24))
                    .frame(width: 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: hoveredAction)
    }

    // MARK: - External Hit-Test & Trigger

    /// Updates hovered action from cursor coordinates and triggers haptics when crossing slice boundaries.
    public func updateHover(cursorDelta: CGPoint) {
        let dx = Double(cursorDelta.x)
        let dy = Double(-cursorDelta.y) // Invert Y
        let newAction = RadialGeometryMath.action(forOffsetDX: dx, dy: dy)

        if newAction != hoveredAction {
            if newAction != nil {
                NSHapticFeedbackManager.defaultPerformer.perform(
                    .alignment,
                    performanceTime: .now
                )
            }
            hoveredAction = newAction
        }
    }

    /// Releases selection and invokes action or cancel.
    public func commitSelection(cursorDelta: CGPoint) {
        let dx = Double(cursorDelta.x)
        let dy = Double(-cursorDelta.y)
        if let chosenAction = RadialGeometryMath.action(forOffsetDX: dx, dy: dy) {
            onSelectAction(chosenAction)
        } else {
            onCancel()
        }
    }
}
