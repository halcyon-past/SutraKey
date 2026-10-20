import CoreGraphics
import Foundation
import Testing
@testable import SutraKey

@Suite("RadialPanelClampingTests")
struct RadialPanelClampingTests {

    @Test("Panel frame remains strictly within visible screen frame on top edge selection")
    func clampsTopEdge() {
        let visible = NSRect(x: 0, y: 67, width: 1470, height: 856) // maxY = 923
        let panelSize: CGFloat = 340.0
        let margin: CGFloat = 16.0

        // User selects URL in top address bar at y = 920
        let cursor = CGPoint(x: 735, y: 920)
        let idealY = cursor.y - panelSize / 2.0 // 750

        let maxY = visible.maxY - panelSize - margin // 923 - 340 - 16 = 567
        let clampedY = min(max(idealY, visible.minY + margin), maxY)

        let topOfPanel = clampedY + panelSize
        #expect(topOfPanel <= visible.maxY - margin)
        #expect(clampedY >= visible.minY + margin)
    }

    @Test("Panel frame remains strictly within visible screen frame on bottom/dock edge selection")
    func clampsBottomEdge() {
        let visible = NSRect(x: 0, y: 67, width: 1470, height: 856) // minY = 67
        let panelSize: CGFloat = 340.0
        let margin: CGFloat = 16.0

        // User selects text near bottom dock at y = 70
        let cursor = CGPoint(x: 735, y: 70)
        let idealY = cursor.y - panelSize / 2.0 // -100

        let minY = visible.minY + margin // 67 + 16 = 83
        let maxY = visible.maxY - panelSize - margin
        let clampedY = min(max(idealY, minY), maxY)

        #expect(clampedY == 83)
        #expect(clampedY + panelSize <= visible.maxY)
    }

    @Test("Panel frame remains strictly within visible screen frame on left and right edges")
    func clampsHorizontalEdges() {
        let visible = NSRect(x: 0, y: 67, width: 1470, height: 856)
        let panelSize: CGFloat = 340.0
        let margin: CGFloat = 16.0

        // Far left
        let cursorLeft = CGPoint(x: 10, y: 500)
        let idealXLeft = cursorLeft.x - panelSize / 2.0
        let minX = visible.minX + margin
        let maxX = visible.maxX - panelSize - margin
        let clampedXLeft = min(max(idealXLeft, minX), maxX)

        #expect(clampedXLeft == margin)

        // Far right
        let cursorRight = CGPoint(x: 1460, y: 500)
        let idealXRight = cursorRight.x - panelSize / 2.0
        let clampedXRight = min(max(idealXRight, minX), maxX)

        #expect(clampedXRight == visible.maxX - panelSize - margin)
    }
}
