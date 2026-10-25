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

    private let menuRadius: CGFloat = 138.0
    private let innerRadius: CGFloat = 40.0
    private let iconRadius: CGFloat = 89.0

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
            // NO BACKGROUND CIRCLE! Floating sleek liquid glass wedges & central jewel hub only.
            
            // 1. Five Independent Floating Liquid Glass Wedges
            ForEach(ConversionAction.allCases) { action in
                sliceView(for: action)
            }

            // 2. Center Convex Liquid Jewel Hub (Dead-zone < 28pt)
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

        // Fluid outward translation on hover (8pt along radial center vector)
        let transX = isHovered ? 8.0 * cos(radians) : 0.0
        let transY = isHovered ? -8.0 * sin(radians) : 0.0

        let wedgeShape = PieWedgeShape(
            startDegrees: startDeg,
            endDegrees: endDeg,
            innerRadius: innerRadius,
            outerRadius: menuRadius,
            gapDegrees: 1.8
        )

        ZStack {
            // 1. Smoked Liquid Glass Body (Balanced 52% translucent optical density)
            if isHovered {
                // Internal fluid illumination radiating outward
                wedgeShape
                    .fill(
                        RadialGradient(
                            colors: [
                                action.accentColor.opacity(0.65),
                                action.accentColor.opacity(0.35),
                                Color(red: 0.04, green: 0.06, blue: 0.12).opacity(0.48)
                            ],
                            center: .center,
                            startRadius: 35,
                            endRadius: 140
                        )
                    )
            } else {
                // Translucent liquid glass prism with subtle obsidian water refraction
                wedgeShape
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.20), location: 0.0),
                                .init(color: Color(red: 0.08, green: 0.11, blue: 0.18).opacity(0.45), location: 0.35),
                                .init(color: Color(red: 0.03, green: 0.04, blue: 0.09).opacity(0.56), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // 2. Liquid Surface Tension Meniscus: Polished Chamfer Rim
            wedgeShape
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(isHovered ? 0.98 : 0.85), location: 0.0),
                            .init(color: isHovered ? action.accentColor : Color.white.opacity(0.35), location: 0.35),
                            .init(color: isHovered ? action.accentColor.opacity(0.50) : Color.white.opacity(0.12), location: 0.65),
                            .init(color: Color.white.opacity(isHovered ? 0.80 : 0.55), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isHovered ? 1.8 : 1.3
                )
                .shadow(
                    color: isHovered ? action.accentColor.opacity(0.90) : Color.black.opacity(0.35),
                    radius: isHovered ? 16 : 8,
                    y: isHovered ? 0 : 4
                )

            // 3. High-Gloss Specular Sheen (Curved liquid glass reflection)
            wedgeShape
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.70), location: 0.0),
                            .init(color: Color.white.opacity(0.0), location: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    ),
                    lineWidth: 2.0
                )

            // 4. Slice Icon & Crisp Short Badge
            VStack(spacing: 3) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundColor(isHovered ? Color.white : Color.white.opacity(0.96))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.95) : Color.black.opacity(0.85), radius: isHovered ? 8 : 3)
                    .shadow(color: Color.black.opacity(0.50), radius: 1)

                Text(action.shortBadge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(0.6)
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.95))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.90) : Color.black.opacity(0.85), radius: isHovered ? 4 : 2)
            }
            .offset(x: posX, y: -posY) // Invert Y for SwiftUI coordinate orientation
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

    // MARK: - Center Hub (Convex Liquid Knot)

    private var centerHubView: some View {
        let activeColor = state.hoveredAction?.accentColor ?? Color(red: 1.0, green: 0.42, blue: 0.24)

        return ZStack {
            // Concentric specular guide ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
                .frame(width: 68, height: 68)

            // Floating Convex Glass Droplet (52pt diameter)
            Circle()
                .fill(
                    state.isCenterHovered
                        ? LinearGradient(
                            stops: [
                                .init(color: Color(red: 0.95, green: 0.20, blue: 0.20).opacity(0.85), location: 0.0),
                                .init(color: Color(red: 0.65, green: 0.08, blue: 0.08).opacity(0.90), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.35), location: 0.0),
                                .init(color: Color(red: 0.08, green: 0.12, blue: 0.20).opacity(0.42), location: 0.35),
                                .init(color: Color(red: 0.04, green: 0.05, blue: 0.10).opacity(0.58), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .frame(width: 52, height: 52)
                // Convex specular highlight
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                stops: [
                                    .init(color: state.isCenterHovered ? Color.red : Color.white.opacity(0.90), location: 0.0),
                                    .init(color: state.isCenterHovered ? Color.red.opacity(0.7) : Color.white.opacity(0.30), location: 0.5),
                                    .init(color: state.isCenterHovered ? Color.red.opacity(0.6) : Color.white.opacity(0.60), location: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.4
                        )
                )
                .shadow(
                    color: state.isCenterHovered ? Color.red.opacity(0.70) : Color.black.opacity(0.40),
                    radius: state.isCenterHovered ? 14 : 8,
                    x: 0,
                    y: 3
                )

            // Core Indicator: Animated Cancel "X" or Glowing Liquid Core
            if state.isCenterHovered {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.6), radius: 4)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Circle()
                    .fill(activeColor)
                    .frame(width: 12, height: 12)
                    .shadow(
                        color: state.hoveredAction != nil ? activeColor.opacity(0.95) : activeColor.opacity(0.50),
                        radius: state.hoveredAction != nil ? 10 : 4
                    )
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .scaleEffect(state.isCenterHovered ? 1.10 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: state.isCenterHovered)
        .animation(.easeInOut(duration: 0.2), value: state.hoveredAction)
    }
}
