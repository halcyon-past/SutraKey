import AppKit
import SwiftUI
import Combine
import AVFoundation
import CoreMedia

// MARK: - Radial Geometry Math & Shapes

public struct PieWedgeShape: Shape {
    public let startDegrees: Double
    public let endDegrees: Double
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat
    public let gapDegrees: Double

    public init(startDegrees: Double, endDegrees: Double, innerRadius: CGFloat, outerRadius: CGFloat, gapDegrees: Double = 0.8) {
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
        path.addArc(center: center, radius: outerRadius, startAngle: .degrees(-e), endAngle: .degrees(-s), clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: .degrees(-s), endAngle: .degrees(-e), clockwise: true)
        path.closeSubpath()
        return path
    }
}

// MARK: - Conversion Actions

public enum DemoAction: String, CaseIterable, Identifiable {
    case video = "video"
    case audio = "audio"
    case subtitles = "subtitles"
    case gallery = "gallery"
    case pdf = "pdf"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .video: return "Video (MP4)"
        case .audio: return "Audio (MP3)"
        case .subtitles: return "Subtitles (SRT)"
        case .gallery: return "Images / Gallery"
        case .pdf: return "Save as PDF"
        }
    }

    public var shortBadge: String {
        switch self {
        case .video: return "MP4"
        case .audio: return "MP3"
        case .subtitles: return "SRT"
        case .gallery: return "IMG"
        case .pdf: return "PDF"
        }
    }

    public var sfSymbol: String {
        switch self {
        case .video: return "film"
        case .audio: return "music.note"
        case .subtitles: return "doc.text"
        case .gallery: return "photo"
        case .pdf: return "book"
        }
    }

    public var accentColor: Color {
        switch self {
        case .video: return Color(red: 1.0, green: 0.42, blue: 0.24) // Vibrant Orange
        case .audio: return Color(red: 0.98, green: 0.75, blue: 0.18) // Amber Gold
        case .subtitles: return Color(red: 0.35, green: 0.80, blue: 0.98) // Cyan Blue
        case .gallery: return Color(red: 0.88, green: 0.40, blue: 0.90) // Magenta / Insta Pink
        case .pdf: return Color(red: 0.30, green: 0.85, blue: 0.55) // Emerald Green
        }
    }

    public var bounds: (Double, Double) {
        switch self {
        case .video: return (0.0, 72.0)
        case .audio: return (72.0, 144.0)
        case .subtitles: return (144.0, 216.0)
        case .gallery: return (216.0, 288.0)
        case .pdf: return (288.0, 360.0)
        }
    }

    public var centerAngle: Double {
        let (s, e) = bounds
        return (s + e) / 2.0
    }
}

// MARK: - Animated Demo Model

public final class DemoTimeline: ObservableObject {
    @Published public var currentTime: Double = 0.0
    @Published public var cursorPosition: CGPoint = CGPoint(x: 480, y: 460)
    @Published public var isLinkSelected: Bool = false
    @Published public var showRadialMenu: Bool = false
    @Published public var hoveredAction: DemoAction? = nil
    @Published public var radialClicked: Bool = false
    @Published public var showToast: Bool = false
    @Published public var toastCompleted: Bool = false
    @Published public var downloadProgress: Double = 0.0
    @Published public var showInstagramBanner: Bool = false
    @Published public var showOutroCard: Bool = false

    private var timer: AnyCancellable?
    private let startTime = Date()

    func start() {
        timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.update(time: Date().timeIntervalSince(self.startTime))
            }
    }

    public func update(time: Double) {
        self.currentTime = time

        // Stage 1: Cursor approaches link (1.2s -> 3.0s)
        let linkPos = CGPoint(x: 480, y: 310)
        let startPos = CGPoint(x: 320, y: 520)

        if time < 1.2 {
            cursorPosition = startPos
        } else if time >= 1.2 && time < 3.0 {
            let progress = easeInOutCubic((time - 1.2) / 1.8)
            cursorPosition = CGPoint(
                x: startPos.x + (linkPos.x - startPos.x) * progress,
                y: startPos.y + (linkPos.y - startPos.y) * progress
            )
        } else if time >= 3.0 && time < 4.2 {
            cursorPosition = linkPos
            isLinkSelected = true
        }

        // Stage 2: Radial Menu blooms (4.2s)
        if time >= 4.2 && time < 8.2 {
            showRadialMenu = true
        } else if time >= 8.2 {
            showRadialMenu = false
        }

        // Stage 3: Cursor moves to "Video (MP4)" slice (5.2s -> 6.8s)
        // Video slice center is at radius 88 at angle 36 deg -> offset (+71, -52) in SwiftUI
        let videoSlicePos = CGPoint(x: linkPos.x + 71, y: linkPos.y - 52)
        if time >= 5.2 && time < 6.8 {
            let p = easeInOutCubic((time - 5.2) / 1.6)
            cursorPosition = CGPoint(
                x: linkPos.x + (videoSlicePos.x - linkPos.x) * p,
                y: linkPos.y + (videoSlicePos.y - linkPos.y) * p
            )
        } else if time >= 6.8 && time < 8.2 {
            cursorPosition = videoSlicePos
            hoveredAction = .video
        }

        // Stage 4: Click video slice at 7.6s
        if time >= 7.6 && time < 8.2 {
            radialClicked = true
        }

        // Stage 5: Toast appears at 8.4s & download runs (8.4s -> 13.5s)
        if time >= 8.4 && time < 14.5 {
            showToast = true
        }
        if time >= 9.0 && time < 13.2 {
            let p = (time - 9.0) / 4.2
            downloadProgress = min(1.0, max(0.0, p))
        } else if time >= 13.2 {
            downloadProgress = 1.0
            toastCompleted = true
        }

        // Stage 6: Instagram feature callout banner (14.0s -> 20.8s)
        if time >= 14.0 && time < 20.8 {
            showInstagramBanner = true
        } else {
            showInstagramBanner = false
        }

        // Stage 7: Viral Outro Card (21.0s -> 26.5s)
        if time >= 21.0 {
            showOutroCard = true
        }

        // Finish at 27.0s
        if time >= 27.0 {
            timer?.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NSApp.terminate(nil)
            }
        }
    }

    public var currentCaption: String? {
        if currentTime >= 0.5 && currentTime < 3.8 {
            return "⚡ Shift + Select any link across macOS"
        } else if currentTime >= 4.2 && currentTime < 7.5 {
            return "✨ Zero-latency radial menu springs around your cursor"
        } else if currentTime >= 7.6 && currentTime < 13.5 {
            return "⚡ 1-Click native MP4 download directly to Downloads"
        } else if currentTime >= 14.0 && currentTime < 20.8 {
            return "📸 Also downloads Instagram Reels & Stories from Private Accounts!"
        } else if currentTime >= 21.0 && currentTime < 27.0 {
            return "📦 brew install --cask halcyon-past/tap/sutrakey"
        }
        return nil
    }

    private func easeInOutCubic(_ t: Double) -> CGFloat {
        let clamped = max(0.0, min(1.0, t))
        return CGFloat(clamped < 0.5 ? 4.0 * clamped * clamped * clamped : 1.0 - pow(-2.0 * clamped + 2.0, 3.0) / 2.0)
    }
}

// MARK: - Main Showcase View

public struct DemoShowcaseView: View {
    @ObservedObject var timeline: DemoTimeline

    public var body: some View {
        ZStack {
            // Ambient Dark Mesh Studio Background
            Color(red: 0.05, green: 0.05, blue: 0.07)
                .ignoresSafeArea()

            // Subtle Background Radial Glow
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.35, blue: 0.15).opacity(0.12),
                    Color(red: 0.55, green: 0.20, blue: 0.85).opacity(0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 700
            )
            .ignoresSafeArea()

            // Main Mockup Window Container
            VStack(spacing: 0) {
                // Window Header Bar with Traffic Lights & URL Pill
                HStack(spacing: 12) {
                    HStack(spacing: 7) {
                        Circle().fill(Color(red: 1.0, green: 0.38, blue: 0.36)).frame(width: 12, height: 12)
                        Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.22)).frame(width: 12, height: 12)
                        Circle().fill(Color(red: 0.16, green: 0.80, blue: 0.37)).frame(width: 12, height: 12)
                    }

                    Spacer()

                    // URL Address Pill
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Text("youtube.com/watch?v=2u19wN1tDT4")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.1), lineWidth: 1))

                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.04))
                .border(Color.white.opacity(0.06), width: 0.5)

                // Web Content Area
                HStack(alignment: .top, spacing: 28) {
                    // Left Column: Video Preview Thumbnail & Metadata
                    VStack(alignment: .leading, spacing: 14) {
                        // Simulated 16:9 Video Player
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.12, green: 0.12, blue: 0.16), Color(red: 0.08, green: 0.08, blue: 0.11)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )

                            // YouTube Play Accent
                            VStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 1.0, green: 0.0, blue: 0.0))
                                        .frame(width: 58, height: 40)
                                        .shadow(color: Color.red.opacity(0.5), radius: 10)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                                Text("APIs Explained in Under 2 Minutes")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            // Duration Badge
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("1:42")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(4)
                                        .padding(8)
                                }
                            }
                        }
                        .frame(width: 440, height: 248)

                        // Channel & Stats
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text("V")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.orange)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("VeriPyed")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Text("67K views • Dec 16, 2024")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 6) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .font(.system(size: 11))
                                Text("2.4K")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(16)
                            .foregroundColor(.white)
                        }
                        .frame(width: 440)
                    }

                    // Right Column: Article / Description with the Target Link
                    VStack(alignment: .leading, spacing: 18) {
                        Text("APIs Explained in Under 2 Minutes")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("What is an API and how does it connect services together? Here is the full animated breakdown with request-response cycles, status codes, and endpoint payloads.")
                            .font(.system(size: 12.5))
                            .lineSpacing(4)
                            .foregroundColor(.white.opacity(0.7))

                        Divider().background(Color.white.opacity(0.1))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("SOURCE VIDEO URL:")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)

                            // THE TARGET LINK PILL
                            HStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(timeline.isLinkSelected ? .orange : .white.opacity(0.8))

                                Text("https://www.youtube.com/watch?v=2u19wN1tDT4")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.white)

                                Spacer()

                                if timeline.isLinkSelected {
                                    HStack(spacing: 4) {
                                        Text("Shift + Select")
                                            .font(.system(size: 9.5, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2.5)
                                            .background(Color.orange.opacity(0.25))
                                            .foregroundColor(.orange)
                                            .cornerRadius(4)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(timeline.isLinkSelected ? Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.22) : Color.white.opacity(0.06))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(timeline.isLinkSelected ? Color.orange : Color.white.opacity(0.12), lineWidth: timeline.isLinkSelected ? 1.8 : 1.0)
                            )
                        }

                        // Feature Highlights Pill
                        HStack(spacing: 12) {
                            featureBadge(icon: "bolt.fill", text: "Zero Latency")
                            featureBadge(icon: "shield.fill", text: "100% Local")
                            featureBadge(icon: "arrow.down.circle.fill", text: "Direct MP4")
                        }
                        .padding(.top, 4)

                        Spacer()
                    }
                }
                .padding(26)

                Spacer()
            }
            .frame(width: 1080, height: 610)
            .background(Color(red: 0.08, green: 0.08, blue: 0.11).opacity(0.92))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.6), radius: 36, x: 0, y: 16)

            // FLOATING RADIAL MENU (Overlayed at Link Coordinates)
            if timeline.showRadialMenu {
                radialMenuView
                    .position(x: 480, y: 310)
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
            }

            // FLOATING SUTRA HUD TOAST (Top Right of Screen)
            if timeline.showToast {
                VStack {
                    HStack {
                        Spacer()
                        sutraToastView
                            .padding(.top, 28)
                            .padding(.trailing, 28)
                    }
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // BOLD INSTAGRAM POWER FEATURE BANNER (Stage 6)
            if timeline.showInstagramBanner {
                instagramFeatureBanner
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            // OUTRO CARD (Stage 7)
            if timeline.showOutroCard {
                outroCardView
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }

            // SIMULATED MACOS CURSOR
            if !timeline.showOutroCard && !timeline.showInstagramBanner {
                cursorView
                    .position(timeline.cursorPosition)
            }

            // VIRAL SUBTITLE / CALLOUT PILL (Bottom Center)
            if let caption = timeline.currentCaption {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Text(caption)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 11)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.94))
                            .overlay(Capsule().stroke(Color.white.opacity(0.24), lineWidth: 1.2))
                    )
                    .shadow(color: Color.black.opacity(0.6), radius: 16, y: 6)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(width: 1280, height: 720)
        .animation(.spring(response: 0.35, dampingFraction: 0.78), value: timeline.showRadialMenu)
        .animation(.spring(response: 0.40, dampingFraction: 0.80), value: timeline.showToast)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: timeline.showInstagramBanner)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: timeline.showOutroCard)
        .animation(.spring(response: 0.25, dampingFraction: 0.70), value: timeline.isLinkSelected)
        .animation(.spring(response: 0.25, dampingFraction: 0.70), value: timeline.hoveredAction)
    }

    // MARK: - Radial Menu Subview

    private var radialMenuView: some View {
        ZStack {
            // Ambient Backdrop Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (timeline.hoveredAction?.accentColor ?? Color.orange).opacity(0.24),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)

            // Frosted Glass Disc
            Circle()
                .fill(Color(red: 0.08, green: 0.08, blue: 0.11).opacity(0.88))
                .overlay(Circle().fill(.ultraThinMaterial))
                .frame(width: 304, height: 304)
                .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1.2))
                .shadow(color: Color.black.opacity(0.65), radius: 26, x: 0, y: 12)

            // 5 Wedges
            ForEach(DemoAction.allCases) { action in
                sliceView(for: action)
            }

            // Center Cancel Knot
            centerKnotView
        }
        .frame(width: 340, height: 340)
    }

    @ViewBuilder
    private func sliceView(for action: DemoAction) -> some View {
        let isHovered = timeline.hoveredAction == action
        let (sDeg, eDeg) = action.bounds
        let angle = action.centerAngle
        let rad = angle * .pi / 180.0

        let posX = 88.0 * cos(rad)
        let posY = 88.0 * sin(rad)
        let transX = isHovered ? 7.0 * cos(rad) : 0.0
        let transY = isHovered ? -7.0 * sin(rad) : 0.0

        let wedge = PieWedgeShape(startDegrees: sDeg, endDegrees: eDeg, innerRadius: 34, outerRadius: 138, gapDegrees: 0.8)

        ZStack {
            if isHovered {
                wedge
                    .fill(action.accentColor.opacity(0.35))
                    .overlay(
                        wedge
                            .stroke(action.accentColor, lineWidth: 2.6)
                            .shadow(color: action.accentColor.opacity(0.9), radius: 10)
                    )
            } else {
                wedge
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        wedge.stroke(Color.white.opacity(0.20), lineWidth: 1.0)
                    )
            }

            VStack(spacing: 3) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.9))
                    .shadow(color: isHovered ? action.accentColor.opacity(0.8) : Color.clear, radius: 8)

                Text(action.shortBadge)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(isHovered ? action.accentColor : Color.white.opacity(0.75))
            }
            .offset(x: posX, y: -posY)
            .scaleEffect(isHovered ? 1.18 : 1.0)
        }
        .offset(x: transX, y: transY)
    }

    private var centerKnotView: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16))
                .frame(width: 54, height: 54)
                .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

            Image(systemName: "arrow.down")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(timeline.hoveredAction?.accentColor ?? .orange)
        }
    }

    // MARK: - Floating Toast HUD Subview

    private var sutraToastView: some View {
        HStack(alignment: .top, spacing: 12) {
            // Animated Status Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(timeline.toastCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .frame(width: 38, height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(timeline.toastCompleted ? Color.green.opacity(0.4) : Color.orange.opacity(0.4), lineWidth: 1)
                    )

                Image(systemName: timeline.toastCompleted ? "checkmark.circle.fill" : "bolt.fill")
                    .font(.system(size: 18))
                    .foregroundColor(timeline.toastCompleted ? .green : .orange)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(timeline.toastCompleted ? "Saved to Downloads" : "SutraKey Started")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("NOW")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Text(timeline.toastCompleted ? "APIs Explained in Under 2 Minutes.mp4" : "Converting to Video (MP4) • youtube.com")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)

                // Mini progress bar while downloading
                if !timeline.toastCompleted {
                    VStack(alignment: .leading, spacing: 2) {
                        ProgressView(value: timeline.downloadProgress, total: 1.0)
                            .progressViewStyle(.linear)
                            .tint(.orange)
                        HStack {
                            Text("\(Int(timeline.downloadProgress * 100))%")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                            Spacer()
                            Text("1080p • 60fps")
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(14)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.10, green: 0.10, blue: 0.14).opacity(0.92))
                .overlay(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.18), lineWidth: 1))
        )
        .shadow(color: Color.black.opacity(0.55), radius: 24, x: 0, y: 10)
    }

    // MARK: - Instagram Power Feature Banner (Stage 6)

    private var instagramFeatureBanner: some View {
        VStack(spacing: 16) {
            // Instagram Gradient Accent Badge
            HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                Text("INSTAGRAM UNLOCKED")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.98, green: 0.20, blue: 0.45), Color(red: 0.98, green: 0.55, blue: 0.18)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: Color.pink.opacity(0.4), radius: 10)

            Text("Download Instagram Reels, Stories & Photos")
                .font(.system(size: 26, weight: .heavy))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Even from Private Accounts you follow — zero password entry required via 1-click Keychain Cookie Sync!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 580)
                .lineSpacing(4)

            HStack(spacing: 14) {
                featureCheck(text: "Private & Public Reels")
                featureCheck(text: "Ephemeral Stories & Highlights")
                featureCheck(text: "Multi-Slide Photo Carousels")
                featureCheck(text: "Direct Keychain Authorization")
            }
            .padding(.top, 4)
        }
        .padding(32)
        .frame(width: 780)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.96))
                .overlay(RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.6), Color.orange.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.8
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.8), radius: 48, x: 0, y: 20)
    }

    // MARK: - Outro Card (Stage 7)

    private var outroCardView: some View {
        VStack(spacing: 20) {
            // App Icon Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.45, blue: 0.20), Color(red: 0.95, green: 0.20, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color.orange.opacity(0.5), radius: 20)

                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 42))
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text("SutraKey (सूत्र)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("Shift + Select Radial Media & Document Downloader for macOS")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }

            // Install Command Box
            HStack(spacing: 10) {
                Text("$")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                Text("brew install --cask halcyon-past/tap/sutrakey")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.18), lineWidth: 1))

            HStack(spacing: 18) {
                Text("⚡ 100% Free & Open Source")
                Text("•")
                Text("🔒 Zero Telemetry")
                Text("•")
                Text("🌐 sutrakey.aritro.cloud")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.secondary)
        }
        .padding(40)
        .frame(width: 760)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.96))
                .overlay(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.2), lineWidth: 1.5))
        )
        .shadow(color: Color.black.opacity(0.85), radius: 50, x: 0, y: 24)
    }

    // MARK: - Cursor Subview

    private var cursorView: some View {
        ZStack {
            // Ripple on click
            if timeline.radialClicked {
                Circle()
                    .stroke(Color.orange.opacity(0.8), lineWidth: 2)
                    .frame(width: 32, height: 32)
                    .scaleEffect(1.8)
                    .opacity(0.0)
                    .animation(.easeOut(duration: 0.4), value: timeline.radialClicked)
            }

            // Crisp Apple Pointer Arrow
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 18))
                path.addLine(to: CGPoint(x: 4.5, y: 14))
                path.addLine(to: CGPoint(x: 8.5, y: 22))
                path.addLine(to: CGPoint(x: 11.5, y: 20.5))
                path.addLine(to: CGPoint(x: 7.5, y: 12.5))
                path.addLine(to: CGPoint(x: 13, y: 12.5))
                path.closeSubpath()
            }
            .fill(Color.white)
            .overlay(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 18))
                    path.addLine(to: CGPoint(x: 4.5, y: 14))
                    path.addLine(to: CGPoint(x: 8.5, y: 22))
                    path.addLine(to: CGPoint(x: 11.5, y: 20.5))
                    path.addLine(to: CGPoint(x: 7.5, y: 12.5))
                    path.addLine(to: CGPoint(x: 13, y: 12.5))
                    path.closeSubpath()
                }
                .stroke(Color.black.opacity(0.85), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 4, x: 1, y: 2)
            .offset(x: 6, y: 9)
        }
    }

    private func featureBadge(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.orange)
            Text(text)
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4.5)
        .background(Color.white.opacity(0.05))
        .cornerRadius(6)
    }

    private func featureCheck(text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 11))
            Text(text)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Main Application & Window Controller

final class DemoAppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let timeline = DemoTimeline()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = DemoShowcaseView(timeline: timeline)

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.titlebarAppearsTransparent = true
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.backgroundColor = NSColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1.0)
        win.contentView = NSHostingView(rootView: contentView)
        win.center()
        win.level = .floating
        win.orderFrontRegardless()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.window = win

        // Start animation loop
        timeline.start()

        // Print window bounds for screen capture
        let f = win.frame
        print("WINDOW_BOUNDS:\(Int(f.origin.x)),\(Int(f.origin.y)),\(Int(f.size.width)),\(Int(f.size.height))")
        fflush(stdout)
    }
}

// MARK: - Direct Offline Video Renderer (Headless AVAssetWriter + ImageRenderer)

func createPixelBuffer(from image: CGImage) -> CVPixelBuffer? {
    let width = image.width
    let height = image.height
    var pixelBuffer: CVPixelBuffer?
    let attrs = [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
    ] as CFDictionary
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

    CVPixelBufferLockBaseAddress(buffer, [])
    let pixelData = CVPixelBufferGetBaseAddress(buffer)
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(
        data: pixelData,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
        space: rgbColorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    )
    context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    CVPixelBufferUnlockBaseAddress(buffer, [])
    return buffer
}

@MainActor
func renderOfflineVideo(outputPath: String, fps: Int32 = 30) async {
    let outURL = URL(fileURLWithPath: outputPath)
    try? FileManager.default.removeItem(at: outURL)

    guard let writer = try? AVAssetWriter(outputURL: outURL, fileType: .mp4) else {
        print("❌ Could not create AVAssetWriter for \(outputPath)")
        return
    }

    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: 2560,
        AVVideoHeightKey: 1440,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 12_000_000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
        ]
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)

    let timeline = DemoTimeline()
    let duration: Double = 27.0
    let totalFrames = Int(duration * Double(fps))

    print("🎬 Rendering \(totalFrames) Retina frames (2560x1440 @ \(fps)fps) directly from SwiftUI...")
    let startTime = Date()

    for frameIndex in 0..<totalFrames {
        let t = Double(frameIndex) / Double(fps)
        timeline.update(time: t)

        let view = DemoShowcaseView(timeline: timeline).frame(width: 1280, height: 720)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0

        guard let cg = renderer.cgImage else {
            print("⚠️ Warning: Could not render CGImage for frame \(frameIndex)")
            continue
        }
        guard let pb = createPixelBuffer(from: cg) else {
            print("⚠️ Warning: Could not create CVPixelBuffer for frame \(frameIndex)")
            continue
        }

        while !input.isReadyForMoreMediaData {
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
        let presentationTime = CMTime(value: Int64(frameIndex), timescale: fps)
        adaptor.append(pb, withPresentationTime: presentationTime)

        if frameIndex % 90 == 0 || frameIndex == totalFrames - 1 {
            let pct = Int((Double(frameIndex + 1) / Double(totalFrames)) * 100)
            let elapsed = Date().timeIntervalSince(startTime)
            let fpsActual = Double(frameIndex + 1) / max(0.01, elapsed)
            print("⏳ [\(pct)%] Frame \(frameIndex + 1)/\(totalFrames) (\(String(format: "%.1f", fpsActual)) fps rendering speed)")
            fflush(stdout)
        }
    }

    input.markAsFinished()
    await writer.finishWriting()
    let totalElapsed = Date().timeIntervalSince(startTime)
    print("✨ Successfully exported raw Retina video in \(String(format: "%.1f", totalElapsed))s: \(outputPath)")
}

@main
enum DemoMain {
    static func main() async {
        if let idx = CommandLine.arguments.firstIndex(of: "--render-offline"), idx + 1 < CommandLine.arguments.count {
            let outPath = CommandLine.arguments[idx + 1]
            let fps: Int32 = 30
            await renderOfflineVideo(outputPath: outPath, fps: fps)
            return
        }

        let app = NSApplication.shared
        app.setActivationPolicy(.regular)
        let delegate = DemoAppDelegate()
        app.delegate = delegate
        app.run()
    }
}
