import CoreGraphics
import Foundation

/// Pure mathematical calculation for radial pie menu geometry, slice partitioning, and dead-zones.
public enum RadialGeometryMath: Sendable {
    /// Center dead-zone radius in points (threshold to cancel selection).
    public static let deadZoneRadius: Double = 28.0

    /// Total number of slices in the radial menu.
    public static let sliceCount: Int = 5

    /// Angular span of each slice in degrees (360° / 5 = 72°).
    public static let sliceSpanDegrees: Double = 360.0 / Double(sliceCount)

    /// Maps a normalized angle in degrees (0° ..< 360°) to one of the 5 conversion actions.
    ///
    /// Ranges:
    /// - [0°, 72°)   -> .video
    /// - [72°, 144°)  -> .audio
    /// - [144°, 216°) -> .subtitles
    /// - [216°, 288°) -> .gallery
    /// - [288°, 360°) -> .pdf
    public static func action(forAngleDegrees rawDegrees: Double) -> ConversionAction {
        guard !rawDegrees.isNaN && !rawDegrees.isInfinite else {
            return .video
        }

        // Normalize degrees into [0, 360)
        var normalized = rawDegrees.truncatingRemainder(dividingBy: 360.0)
        if normalized < 0.0 {
            normalized += 360.0
        }

        let sliceIndex = Int(normalized / sliceSpanDegrees)
        switch sliceIndex {
        case 0:
            return .video
        case 1:
            return .audio
        case 2:
            return .subtitles
        case 3:
            return .gallery
        default:
            return .pdf
        }
    }

    /// Evaluates cursor distance and angle relative to the center origin.
    /// Returns `.none` (nil) if within the < 28pt center dead-zone.
    public static func action(forDistance distance: Double, angleDegrees: Double) -> ConversionAction? {
        guard distance >= deadZoneRadius else {
            return nil
        }
        return action(forAngleDegrees: angleDegrees)
    }

    /// Evaluates cursor Cartesian offset (dx, dy) relative to center.
    /// Returns `.none` (nil) if within the < 28pt center dead-zone.
    public static func action(forOffsetDX dx: Double, dy: Double) -> ConversionAction? {
        let distance = hypot(dx, dy)
        guard distance >= deadZoneRadius else {
            return nil
        }

        // Calculate angle where 0° is along positive X axis
        var angle = atan2(dy, dx) * 180.0 / .pi
        if angle < 0.0 {
            angle += 360.0
        }
        return action(forAngleDegrees: angle)
    }

    /// Evaluates a point relative to center point.
    public static func action(forCursor point: CGPoint, center: CGPoint) -> ConversionAction? {
        let dx = Double(point.x - center.x)
        let dy = Double(point.y - center.y)
        return action(forOffsetDX: dx, dy: dy)
    }

    /// Returns the center angle (in degrees) for a given conversion action.
    public static func centerAngle(for action: ConversionAction) -> Double {
        switch action {
        case .video:
            return 36.0
        case .audio:
            return 108.0
        case .subtitles:
            return 180.0
        case .gallery:
            return 252.0
        case .pdf:
            return 324.0
        }
    }
}
