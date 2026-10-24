import Foundation
import Testing
@testable import SutraKey

@Suite("EphemeralMenuBarStateTests", .serialized)
struct EphemeralMenuBarStateTests {

    @Test("Menu bar icon is strictly hidden on launch when idle")
    @MainActor
    func testMenuBarHiddenOnLaunch() {
        let originalPref = PreferencesManager.shared.keepStatusBarVisible
        defer { PreferencesManager.shared.keepStatusBarVisible = originalPref }
        PreferencesManager.shared.keepStatusBarVisible = false

        let controller = EphemeralStatusBarController()
        controller.hideStatusItem()

        #expect(controller.activeTasks.isEmpty)
        #expect(controller.isIconVisible == false)
    }

    @Test("Menu bar icon is visible on launch when keepStatusBarVisible is true")
    @MainActor
    func testMenuBarVisibleWhenPreferenceEnabled() {
        let originalPref = PreferencesManager.shared.keepStatusBarVisible
        defer { PreferencesManager.shared.keepStatusBarVisible = originalPref }
        PreferencesManager.shared.keepStatusBarVisible = true

        let controller = EphemeralStatusBarController()
        controller.updateVisibility()

        #expect(controller.isIconVisible == true)
    }

    @Test("Menu bar appears on task start and hides on finish")
    @MainActor
    func testMenuBarAppearsOnTaskStartAndHidesOnFinish() {
        let originalPref = PreferencesManager.shared.keepStatusBarVisible
        defer { PreferencesManager.shared.keepStatusBarVisible = originalPref }
        PreferencesManager.shared.keepStatusBarVisible = false

        let controller = EphemeralStatusBarController()
        controller.hideStatusItem()
        controller.completionGracePeriodSeconds = 0.0 // Synchronous dismissal for tests

        var startNotificationFired = false
        var completeNotificationFired = false

        controller.onTaskStartedNotification = { job in
            startNotificationFired = true
        }

        controller.onTaskCompletedNotification = { job in
            completeNotificationFired = true
        }

        guard let testURL = URL(string: "https://example.com/video") else {
            Issue.record("Invalid test URL")
            return
        }

        let mockJob = ConversionJob(
            id: UUID(),
            sourceURL: testURL,
            action: .video,
            title: "Test Video",
            domain: "example.com",
            progress: 0.1,
            status: .downloading
        )

        // 1. Task Starts: Menu bar icon must appear and trigger start notification
        controller.taskDidStart(mockJob)
        #expect(controller.isIconVisible == true)
        #expect(startNotificationFired == true)
        #expect(controller.activeTasks.count == 1)

        // 2. Task Completes: Menu bar icon must hide after grace period (0.0s in test)
        controller.taskDidComplete(mockJob)
        #expect(completeNotificationFired == true)
        #expect(controller.activeTasks.isEmpty)
        #expect(controller.isIconVisible == false)
    }

    @Test("Status bar right-click menu items are all enabled and wired to targets")
    @MainActor
    func testContextMenuItemsEnabled() {
        let controller = EphemeralStatusBarController.shared
        let menu = controller.createContextMenu()
        menu.update()

        #expect(menu.autoenablesItems == false)
        #expect(menu.items.count >= 5)

        for item in menu.items where !item.isSeparatorItem {
            #expect(item.target === controller)
            #expect(item.isEnabled == true)
            #expect(controller.validateMenuItem(item) == true)
        }

        let quitItem = menu.items.first { $0.title.contains("Quit") }
        #expect(quitItem != nil)
        #expect(quitItem?.action == #selector(controller.quitApp(_:)))
        #expect(quitItem?.isEnabled == true)
    }
}
