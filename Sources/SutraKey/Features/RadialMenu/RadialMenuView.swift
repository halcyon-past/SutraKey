import AppKit
import SwiftUI

/// Mathematical pie sector shape used for drawing slices and defining pixel-perfect button hitboxes.
public struct PieWedgeShape: Shape {
    public let startDegrees: Double
    public let endDegrees: Double
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat

    public init(startDegrees: Double, endDegrees: Double, innerRadius: CGFloat, outerRadius: CGFloat) {
        self.startDegrees = startDegrees
        self.endDegrees = endDegrees
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
    }

    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        // In SwiftUI, 0° is +X (right), -90° is -Y (up).
        // Cartesian [startDegrees, endDegrees] maps to SwiftUI [-.degrees(endDegrees), -.degrees(startDegrees)]
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: .degrees(-endDegrees),
            endAngle: .degrees(-startDegrees),
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: .degrees(-startDegrees),
            endAngle: .degrees(-endDegrees),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

/// Fluid SwiftUI radial pie menu rendered under the mouse cursor.
public struct RadialMenuView: View {
    public let url: URL
    public let onSelectAction: (ConversionAction) -> Void
    public let onCancel: () -> Void

    @State private var hoveredAction: ConversionAction?
    @State private var appeared: Bool = false

    private let menuRadius: CGFloat = 148.0
    private let innerRadius: CGFloat = 36.0

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
            // Background blur disc with frosted border & shadow
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: menuRadius * 2, height: menuRadius * 2)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 12)

            // 5 Interactive Radial Pie Wedges
            ForEach(ConversionAction.allCases) { action in
                sliceView(for: action)
            }

            // Center Dead-Zone (< 28pt) Hub with cancel knot
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
        let (startDeg, endDeg) = sliceAngleBounds(for: action)
        let centerAngle = RadialGeometryMath.centerAngle(for: action)
        let radians = centerAngle * .pi / 180.0
        let iconRadius: CGFloat = (innerRadius + menuRadius) / 2.0

        let posX = iconRadius * cos(radians)
        let posY = iconRadius * sin(radians)

        let wedgeShape = PieWedgeShape(
            startDegrees: startDeg,
            endDegrees: endDeg,
            innerRadius: innerRadius,
            outerRadius: menuRadius
        )

        Button(action: {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
            onSelectAction(action)
        }) {
            ZStack {
                // Pie Sector Background
                wedgeShape
                    .fill(
                        isHovered
                            ? action.accentColor.opacity(0.32)
                            : Color.white.opacity(0.04)
                    )

                if isHovered {
                    wedgeShape
                        .stroke(action.accentColor.opacity(0.85), lineWidth: 1.5)
                }

                // Slice Icon + Short Badge
                VStack(spacing: 3) {
                    Image(systemName: action.sfSymbol)
                        .font(.system(size: isHovered ? 24 : 18, weight: .semibold))
                        .foregroundColor(isHovered ? action.accentColor : .white.opacity(0.9))

                    Text(action.shortBadge)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(isHovered ? .white : .white.opacity(0.75))
                }
                .offset(x: posX, y: -posY) // Flip Y for SwiftUI coordinate space
                .scaleEffect(isHovered ? 1.15 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .contentShape(wedgeShape)
        .onHover { hovering in
            if hovering {
                if hoveredAction != action {
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                    hoveredAction = action
                }
            } else if hoveredAction == action {
                hoveredAction = nil
            }
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.68), value: isHovered)
    }

    private func sliceAngleBounds(for action: ConversionAction) -> (Double, Double) {
        switch action {
        case .video:
            return (0.0, 72.0)
        case .audio:
            return (72.0, 144.0)
        case .subtitles:
            return (144.0, 216.0)
        case .gallery:
            return (216.0, 288.0)
        case .pdf:
            return (288.0, 360.0)
        }
    }

    // MARK: - Center Hub

    private var centerHubView: some View {
        Button(action: {
            onCancel()
        }) {
            ZStack {
                Circle()
                    .fill(Color(white: 0.12, opacity: 0.95))
                    .frame(width: RadialGeometryMath.deadZoneRadius * 2, height: RadialGeometryMath.deadZoneRadius * 2)
                    .overlay(
                        Circle()
                            .stroke(
                                hoveredAction != nil ? hoveredAction!.accentColor.opacity(0.8) : Color.white.opacity(0.25),
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
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .animation(.easeInOut(duration: 0.18), value: hoveredAction)
    }

    // MARK: - External Hit-Test & Trigger

    /// Updates hovered action from cursor coordinates and triggers haptics when crossing slice boundaries.
    public func updateHover(cursorDelta: CGPoint) {
        let dx = Double(cursorDelta.x)
        let dy = Double(cursorDelta.y) // in Cocoa delta, dy is already Cocoa screen Y (positive up)
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
        let dy = Double(cursorDelta.y)
        if let chosenAction = RadialGeometryMath.action(forOffsetDX: dx, dy: dy) {
            onSelectAction(chosenAction)
        } else {
            onCancel()
        }
    }
}
