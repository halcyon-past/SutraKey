import AppKit
import SwiftUI

/// Observable state driving slice highlights and center cancel knot without view hierarchy masking.
@MainActor
public final class RadialMenuState: ObservableObject {
    @Published public var hoveredAction: ConversionAction? = nil
    @Published public var isCenterHovered: Bool = false
    public init() {}
}

/// Mathematical pie sector shape used for drawing slices with discrete hairline gaps.
public struct PieWedgeShape: Shape {
    public let startDegrees: Double
    public let endDegrees: Double
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat
    public let gapDegrees: Double

    public init(
        startDegrees: Double,
        endDegrees: Double,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        gapDegrees: Double = 0.8
    ) {
        self.startDegrees = startDegrees
        self.endDegrees = endDegrees
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.gapDegrees = gapDegrees
    }

    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let s = startDegrees + gapDegrees
        let e = endDegrees - gapDegrees
        // In SwiftUI, 0° is +X (right), -90° is -Y (up).
        // Cartesian [s, e] maps to SwiftUI [-.degrees(e), -.degrees(s)]
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: .degrees(-e),
            endAngle: .degrees(-s),
            clockwise: false
        )
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: .degrees(-s),
            endAngle: .degrees(-e),
            clockwise: true
        )
        path.closeSubpath()
        return path
    }
}

/// Fluid SwiftUI radial pie menu rendered under the mouse cursor, matching the web simulator dial.
public struct RadialMenuView: View {
    @ObservedObject public var state: RadialMenuState
    public let url: URL
    public let onSelectAction: (ConversionAction) -> Void
    public let onCancel: () -> Void

    @State private var appeared: Bool = false

    private let menuRadius: CGFloat = 142.0
    private let innerRadius: CGFloat = 34.0
    private let iconRadius: CGFloat = 88.0

    public init(
        state: RadialMenuState,
        url: URL,
        onSelectAction: @escaping (ConversionAction) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.state = state
        self.url = url
        self.onSelectAction = onSelectAction
        self.onCancel = onCancel
    }

    public var body: some View {
        ZStack {
            // Ambient soft background glow responding to active hovered slice
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (state.hoveredAction?.accentColor ?? Color(red: 1.0, green: 0.42, blue: 0.24))
                                .opacity(state.hoveredAction != nil ? 0.20 : 0.04),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 24,
                        endRadius: 156
                    )
                )
                .frame(width: 320, height: 320)

            // Outer Circular Frosted Glass Backdrop Disc (matching web simulator)
            Circle()
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.85))
                .overlay(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                .frame(width: 312, height: 312)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.16), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.60), radius: 28, x: 0, y: 12)

            // 5 Discrete Radial Pie Wedges
            ForEach(ConversionAction.allCases) { action in
                sliceView(for: action)
            }

            // Center Dead-Zone (< 28pt) Cancel Knot
            centerHubView
        }
        .frame(width: 340, height: 340)
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
        let isHovered = state.hoveredAction == action
        let (startDeg, endDeg) = sliceAngleBounds(for: action)
        let centerAngle = RadialGeometryMath.centerAngle(for: action)
        let radians = centerAngle * .pi / 180.0

        let posX = iconRadius * cos(radians)
        let posY = iconRadius * sin(radians)

        // Wedge outward translation on hover (6pt along radial center vector)
        let transX = isHovered ? 6.0 * cos(radians) : 0.0
        let transY = isHovered ? -6.0 * sin(radians) : 0.0

        let wedgeShape = PieWedgeShape(
            startDegrees: startDeg,
            endDegrees: endDeg,
            innerRadius: innerRadius,
            outerRadius: menuRadius,
            gapDegrees: 0.8
        )

        ZStack {
            // Pie Sector Background with discrete gap and neon glow on hover
            if isHovered {
                wedgeShape
                    .fill(action.accentColor.opacity(0.32))
                    .overlay(
                        wedgeShape
                            .stroke(action.accentColor, lineWidth: 2.4)
                            .shadow(color: action.accentColor.opacity(0.85), radius: 8)
                    )
            } else {
                wedgeShape
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        wedgeShape
                            .stroke(Color.white.opacity(0.20), lineWidth: 1.0)
                    )
            }

            // Slice Icon + Short Badge
            VStack(spacing: 3) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.88))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.75) : Color.clear, radius: 6)

                Text(action.shortBadge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.5)
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.75))
            }
            .offset(x: posX, y: -posY) // Flip Y for SwiftUI coordinate space
            .scaleEffect(isHovered ? 1.15 : 1.0)
        }
        .offset(x: transX, y: transY)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isHovered)
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
        let activeColor = state.hoveredAction?.accentColor ?? Color(red: 1.0, green: 0.42, blue: 0.24)

        return ZStack {
            // Subtle concentric machined groove ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 1.0)
                .frame(width: 64, height: 64)

            // Center Knob Base Disc (56pt diameter)
            Circle()
                .fill(
                    state.isCenterHovered
                        ? Color.red.opacity(0.22)
                        : (state.hoveredAction != nil
                            ? Color.white.opacity(0.10)
                            : Color(red: 0.10, green: 0.10, blue: 0.13).opacity(0.95))
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .stroke(
                            state.isCenterHovered
                                ? Color.red
                                : (state.hoveredAction != nil ? Color.white.opacity(0.30) : Color.white.opacity(0.18)),
                            lineWidth: state.isCenterHovered ? 2.0 : 1.2
                        )
                )
                .shadow(
                    color: state.isCenterHovered ? Color.red.opacity(0.40) : Color.black.opacity(0.35),
                    radius: state.isCenterHovered ? 10 : 6
                )

            // Core Indicator: Cancel "X" or Glowing Neon Sutra Dot
            if state.isCenterHovered {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .fill(activeColor)
                    .frame(width: 12, height: 12)
                    .shadow(
                        color: state.hoveredAction != nil ? activeColor.opacity(0.95) : Color.clear,
                        radius: 8
                    )
                    .shadow(
                        color: state.hoveredAction != nil ? activeColor.opacity(0.60) : Color.clear,
                        radius: 14
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .scaleEffect(state.isCenterHovered ? 1.10 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: state.isCenterHovered)
        .animation(.easeInOut(duration: 0.2), value: state.hoveredAction)
    }
}
