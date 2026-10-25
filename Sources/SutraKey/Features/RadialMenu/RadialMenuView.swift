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

/// Fluid SwiftUI radial pie menu rendered under the mouse cursor in an Apple Liquid Glass aesthetic.
public struct RadialMenuView: View {
    @ObservedObject public var state: RadialMenuState
    public let url: URL
    public let onSelectAction: (ConversionAction) -> Void
    public let onCancel: () -> Void

    @State private var appeared: Bool = true

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
            // 1. Ambient Dynamic Caustic Dispersion (responds fluidly to hovered action)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (state.hoveredAction?.accentColor ?? Color(red: 1.0, green: 0.42, blue: 0.24))
                                .opacity(state.hoveredAction != nil ? 0.28 : 0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .frame(width: 330, height: 330)

            // 2. Liquid Glass Backdrop Disc (Dark smoke tint with specular curvature)
            Circle()
                .fill(Color(red: 0.06, green: 0.06, blue: 0.09).opacity(0.82))
                .overlay(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
                // Diagonal liquid refractive gloss sheen
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.18), location: 0.0),
                                    .init(color: Color.white.opacity(0.04), location: 0.35),
                                    .init(color: Color.clear, location: 0.55),
                                    .init(color: Color.white.opacity(0.08), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: 312, height: 312)
                // Liquid Chamfer: Dual-layer specular edge highlight + dark refraction inner ring
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.50), location: 0.0),
                                    .init(color: Color.white.opacity(0.16), location: 0.35),
                                    .init(color: Color.white.opacity(0.05), location: 0.65),
                                    .init(color: Color.white.opacity(0.30), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.4
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.40), lineWidth: 0.8)
                        .padding(1.2)
                )
                .shadow(color: Color.black.opacity(0.68), radius: 32, x: 0, y: 14)
                .shadow(
                    color: (state.hoveredAction?.accentColor ?? Color.clear).opacity(0.18),
                    radius: 20,
                    x: 0,
                    y: 2
                )

            // 3. Five Discrete Liquid Prismatic Wedges
            ForEach(ConversionAction.allCases) { action in
                sliceView(for: action)
            }

            // 4. Center Convex Liquid Jewel Hub (Dead-zone < 28pt)
            centerHubView
        }
        .frame(width: 340, height: 340)
        .scaleEffect(appeared ? 1.0 : 0.82)
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

        // Fluid outward translation on hover (6pt along radial center vector)
        let transX = isHovered ? 6.0 * cos(radians) : 0.0
        let transY = isHovered ? -6.0 * sin(radians) : 0.0

        let wedgeShape = PieWedgeShape(
            startDegrees: startDeg,
            endDegrees: endDeg,
            innerRadius: innerRadius,
            outerRadius: menuRadius,
            gapDegrees: 0.85
        )

        ZStack {
            // Liquid Sector Body
            if isHovered {
                // Fluid caustic flood fill
                wedgeShape
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: action.accentColor.opacity(0.46), location: 0.0),
                                .init(color: action.accentColor.opacity(0.20), location: 0.65),
                                .init(color: action.accentColor.opacity(0.34), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    // High-gloss liquid specular rim
                    .overlay(
                        wedgeShape
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: Color.white.opacity(0.85), location: 0.0),
                                        .init(color: action.accentColor, location: 0.40),
                                        .init(color: action.accentColor.opacity(0.45), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2.0
                            )
                            .shadow(color: action.accentColor.opacity(0.80), radius: 10)
                    )
            } else {
                // Clear liquid glass prism (unhovered)
                wedgeShape
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.08), location: 0.0),
                                .init(color: Color.white.opacity(0.02), location: 0.55),
                                .init(color: Color.white.opacity(0.05), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        wedgeShape
                            .stroke(
                                LinearGradient(
                                    stops: [
                                        .init(color: Color.white.opacity(0.26), location: 0.0),
                                        .init(color: Color.white.opacity(0.08), location: 0.5),
                                        .init(color: Color.white.opacity(0.18), location: 1.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.0
                            )
                    )
            }

            // Slice Icon & Crisp Short Badge
            VStack(spacing: 3) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isHovered ? Color.white : Color.white.opacity(0.92))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.95) : Color.black.opacity(0.35), radius: isHovered ? 8 : 2)
                    .shadow(color: isHovered ? Color.white.opacity(0.40) : Color.clear, radius: 2)

                Text(action.shortBadge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.6)
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.80))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.70) : Color.black.opacity(0.30), radius: isHovered ? 4 : 1)
            }
            .offset(x: posX, y: -posY) // Invert Y for SwiftUI coordinate orientation
            .scaleEffect(isHovered ? 1.14 : 1.0)
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

    // MARK: - Center Hub (Convex Liquid Knot)

    private var centerHubView: some View {
        let activeColor = state.hoveredAction?.accentColor ?? Color(red: 1.0, green: 0.42, blue: 0.24)

        return ZStack {
            // Subtle concentric liquid guide ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
                .frame(width: 64, height: 64)

            // Convex Liquid Jewel Knob Base (56pt diameter)
            Circle()
                .fill(
                    state.isCenterHovered
                        ? Color(red: 0.30, green: 0.05, blue: 0.05).opacity(0.88)
                        : (state.hoveredAction != nil
                            ? Color.white.opacity(0.12)
                            : Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.94))
                )
                // Convex specular lens highlight
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.28), location: 0.0),
                                    .init(color: Color.white.opacity(0.04), location: 0.45),
                                    .init(color: Color.clear, location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: state.isCenterHovered ? Color.red : Color.white.opacity(0.55), location: 0.0),
                                    .init(color: state.isCenterHovered ? Color.red.opacity(0.6) : Color.white.opacity(0.14), location: 0.5),
                                    .init(color: state.isCenterHovered ? Color.red.opacity(0.8) : Color.white.opacity(0.30), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: state.isCenterHovered ? 2.0 : 1.4
                        )
                )
                .shadow(
                    color: state.isCenterHovered ? Color.red.opacity(0.55) : Color.black.opacity(0.40),
                    radius: state.isCenterHovered ? 12 : 7
                )

            // Core Indicator: Animated Cancel "X" or Glowing Liquid Core
            if state.isCenterHovered {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
                    .shadow(color: Color.red.opacity(0.8), radius: 6)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .fill(activeColor)
                    .frame(width: 12, height: 12)
                    .shadow(
                        color: state.hoveredAction != nil ? activeColor.opacity(0.95) : activeColor.opacity(0.50),
                        radius: state.hoveredAction != nil ? 10 : 4
                    )
                    .shadow(
                        color: state.hoveredAction != nil ? activeColor.opacity(0.60) : Color.clear,
                        radius: 16
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .scaleEffect(state.isCenterHovered ? 1.10 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: state.isCenterHovered)
        .animation(.easeInOut(duration: 0.2), value: state.hoveredAction)
    }
}
