import CoreGraphics
import Testing
@testable import SutraKey

@Suite("RadialGeometryTests")
struct RadialGeometryTests {

    @Test("Cursor distance < 28.0 pts from origin returns .none")
    func testCenterDeadZoneCancelsSelection() {
        // Points strictly within deadzone radius (28.0)
        let deadZoneOffsets: [(Double, Double)] = [
            (0.0, 0.0),
            (10.0, 10.0),
            (0.0, 27.9),
            (27.9, 0.0),
            (-15.0, 15.0),
            (-20.0, -10.0)
        ]

        for (dx, dy) in deadZoneOffsets {
            let result = RadialGeometryMath.action(forOffsetDX: dx, dy: dy)
            #expect(result == .none, "Expected .none for offset (\(dx), \(dy)) within dead zone")
        }

        // Direct distance check
        #expect(RadialGeometryMath.action(forDistance: 15.0, angleDegrees: 45.0) == .none)
        #expect(RadialGeometryMath.action(forDistance: 27.99, angleDegrees: 180.0) == .none)

        // Beyond dead zone should resolve to a valid action
        #expect(RadialGeometryMath.action(forDistance: 28.1, angleDegrees: 45.0) != .none)
        #expect(RadialGeometryMath.action(forDistance: 50.0, angleDegrees: 180.0) != .none)
    }

    @Test("Five slice angle mapping partitions 360 degrees deterministically")
    func testFiveSliceAngleMapping() {
        // Slice 1: Video (0° ..< 72°)
        let videoAngles = [0.0, 1.0, 36.0, 71.99]
        for angle in videoAngles {
            #expect(RadialGeometryMath.action(forAngleDegrees: angle) == .video, "Failed for angle \(angle)")
        }

        // Slice 2: Audio (72° ..< 144°)
        let audioAngles = [72.0, 75.0, 108.0, 143.99]
        for angle in audioAngles {
            #expect(RadialGeometryMath.action(forAngleDegrees: angle) == .audio, "Failed for angle \(angle)")
        }

        // Slice 3: Subtitles (144° ..< 216°)
        let subtitleAngles = [144.0, 150.0, 180.0, 215.99]
        for angle in subtitleAngles {
            #expect(RadialGeometryMath.action(forAngleDegrees: angle) == .subtitles, "Failed for angle \(angle)")
        }

        // Slice 4: Gallery (216° ..< 288°)
        let galleryAngles = [216.0, 220.0, 252.0, 287.99]
        for angle in galleryAngles {
            #expect(RadialGeometryMath.action(forAngleDegrees: angle) == .gallery, "Failed for angle \(angle)")
        }

        // Slice 5: PDF (288° ..< 360°)
        let pdfAngles = [288.0, 300.0, 324.0, 359.99]
        for angle in pdfAngles {
            #expect(RadialGeometryMath.action(forAngleDegrees: angle) == .pdf, "Failed for angle \(angle)")
        }

        // Boundary edge case: 360° wraps to 0° (.video)
        #expect(RadialGeometryMath.action(forAngleDegrees: 360.0) == .video)
        #expect(RadialGeometryMath.action(forAngleDegrees: 720.0) == .video)

        // Negative angle wrap: -10° -> 350° (.pdf)
        #expect(RadialGeometryMath.action(forAngleDegrees: -10.0) == .pdf)

        // Robustness: NaN or Infinite angles fallback safely to .video without crashing
        #expect(RadialGeometryMath.action(forAngleDegrees: .nan) == .video)
        #expect(RadialGeometryMath.action(forAngleDegrees: .infinity) == .video)
    }

    @Test("Hit tests match Cartesian orientations accurately for flipped views")
    func testFlippedViewHitTestingAccuracy() {
        let center = CGPoint(x: 170.0, y: 170.0)
        // Video: top-right (x > center.x, y < center.y)
        let videoLoc = CGPoint(x: 242.0, y: 117.0)
        let videoAction = RadialGeometryMath.action(forOffsetDX: Double(videoLoc.x - center.x), dy: Double(center.y - videoLoc.y))
        #expect(videoAction == .video)

        // Audio: top-left (x < center.x, y < center.y)
        let audioLoc = CGPoint(x: 142.0, y: 84.0)
        let audioAction = RadialGeometryMath.action(forOffsetDX: Double(audioLoc.x - center.x), dy: Double(center.y - audioLoc.y))
        #expect(audioAction == .audio)

        // Subtitles: left (x < center.x, y == center.y)
        let subLoc = CGPoint(x: 80.0, y: 170.0)
        let subAction = RadialGeometryMath.action(forOffsetDX: Double(subLoc.x - center.x), dy: Double(center.y - subLoc.y))
        #expect(subAction == .subtitles)

        // Gallery: bottom-left (x < center.x, y > center.y)
        let galLoc = CGPoint(x: 142.0, y: 255.0)
        let galAction = RadialGeometryMath.action(forOffsetDX: Double(galLoc.x - center.x), dy: Double(center.y - galLoc.y))
        #expect(galAction == .gallery)

        // PDF: bottom-right (x > center.x, y > center.y)
        let pdfLoc = CGPoint(x: 242.0, y: 222.0)
        let pdfAction = RadialGeometryMath.action(forOffsetDX: Double(pdfLoc.x - center.x), dy: Double(center.y - pdfLoc.y))
        #expect(pdfAction == .pdf)
    }
}
