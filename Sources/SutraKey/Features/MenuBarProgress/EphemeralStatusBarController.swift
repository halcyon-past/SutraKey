import AppKit
import Foundation
import os
import SwiftUI

/// Controls the NSStatusItem in the macOS Menu Bar.
/// Supports both ephemeral presence (strictly while active conversion tasks are running)
/// and persistent presence based on user preferences.
@MainActor
public final class EphemeralStatusBarController: NSObject, ObservableObject {
    public static let shared = EphemeralStatusBarController()

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var dismissTimer: Timer?

    /// Publicly observable state for tests and UI guards.
    @Published public private(set) var isIconVisible: Bool = false

    /// Active jobs currently reflected in the menu bar popover.
    @Published public private(set) var activeTasks: [ConversionJob] = []

    /// Recent finished jobs for quick Finder / playback access.
    @Published public private(set) var recentCompletedTasks: [ConversionJob] = []

    /// Grace period before status bar item hides after all jobs finish (1.5 seconds by default).
    public var completionGracePeriodSeconds: Double = 1.5

    /// Flag controlling whether physical NSStatusBar item should be created.
    /// Disabled automatically in headless CI/CD runners to prevent WindowServer CGSConnection aborts.
    public var allowsSystemStatusItem: Bool = {
        if ProcessInfo.processInfo.environment["CI"] != nil ||
           ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] != nil ||
           ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return false
        }
        return true
    }()

    /// Notification hooks fired for testing and HUD toasts.
    public var onTaskStartedNotification: ((ConversionJob) -> Void)?
    public var onTaskCompletedNotification: ((ConversionJob) -> Void)?
    public var onTaskFailedNotification: ((ConversionJob, String) -> Void)?

    public override init() {
        super.init()
        self.isIconVisible = false
    }

    /// Task start lifecycle hook.
    public func taskDidStart(_ job: ConversionJob) {
        dismissTimer?.invalidate()
        dismissTimer = nil

        if !activeTasks.contains(where: { $0.id == job.id }) {
            activeTasks.append(job)
        }

        updateVisibility()
        updateStatusItemDisplay()
        onTaskStartedNotification?(job)
    }

    /// Task progress / status update lifecycle hook.
    public func taskDidUpdate(_ job: ConversionJob) {
        if let index = activeTasks.firstIndex(where: { $0.id == job.id }) {
            activeTasks[index] = job
        }
        updateStatusItemDisplay()
    }

    /// Task completion lifecycle hook.
    public func taskDidComplete(_ job: ConversionJob) {
        activeTasks.removeAll(where: { $0.id == job.id })

        // Prepend to recent tasks (keep last 5)
        var updatedRecent = recentCompletedTasks.filter { $0.id != job.id }
        updatedRecent.insert(job, at: 0)
        if updatedRecent.count > 5 {
            updatedRecent = Array(updatedRecent.prefix(5))
        }
        self.recentCompletedTasks = updatedRecent

        if PreferencesManager.shared.playCompletionSound {
            NSSound(named: "Glass")?.play()
        }

        onTaskCompletedNotification?(job)
        scheduleGracefulDismissal()
    }

    /// Task failure lifecycle hook.
    public func taskDidFail(_ job: ConversionJob, error: String) {
        activeTasks.removeAll(where: { $0.id == job.id })
        onTaskFailedNotification?(job, error)
        scheduleGracefulDismissal()
    }

    // MARK: - Visibility Management

    private func scheduleGracefulDismissal() {
        guard activeTasks.isEmpty else {
            updateStatusItemDisplay()
            return
        }

        // If user configured menu bar icon to always stay visible:
        if PreferencesManager.shared.keepStatusBarVisible {
            updateStatusItemDisplay()
            return
        }

        dismissTimer?.invalidate()
        if completionGracePeriodSeconds <= 0.0 {
            self.hideStatusItem()
        } else {
            dismissTimer = Timer.scheduledTimer(withTimeInterval: completionGracePeriodSeconds, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self, self.activeTasks.isEmpty else { return }
                    if !PreferencesManager.shared.keepStatusBarVisible {
                        self.hideStatusItem()
                    } else {
                        self.updateStatusItemDisplay()
                    }
                }
            }
        }
    }

    /// Explicitly hide status item (used by timers or tests).
    public func hideStatusItem() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        isIconVisible = false
        if let item = statusItem {
            item.isVisible = false
            if allowsSystemStatusItem {
                NSStatusBar.system.removeStatusItem(item)
            }
            statusItem = nil
        }
        popover?.close()
    }

    public func updateVisibility() {
        let shouldBeVisible = !activeTasks.isEmpty || PreferencesManager.shared.keepStatusBarVisible
        if shouldBeVisible {
            isIconVisible = true
            setupStatusItemIfNeeded()
            updateStatusItemDisplay()
        } else {
            hideStatusItem()
        }
    }

    private func setupStatusItemIfNeeded() {
        guard allowsSystemStatusItem else { return }
        guard statusItem == nil else {
            statusItem?.isVisible = true
            updateStatusItemDisplay()
            return
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.isVisible = true

        if let button = item.button {
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        self.statusItem = item
        updateStatusItemDisplay()
    }

    private func loadMenuBarIcon() -> NSImage? {
        #if SWIFT_PACKAGE
        if let img = Bundle.module.image(forResource: "MenuBarIcon") {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }
        if let url = Bundle.module.url(forResource: "MenuBarIcon@2x", withExtension: "png", subdirectory: "Assets.xcassets/MenuBarIcon.imageset") ??
                     Bundle.module.url(forResource: "MenuBarIcon@1x", withExtension: "png", subdirectory: "Assets.xcassets/MenuBarIcon.imageset"),
           let img = NSImage(contentsOf: url) {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }
        #endif

        if let img = Bundle.main.image(forResource: "MenuBarIcon") {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }

        if let path = Bundle.main.path(forResource: "MenuBarIcon", ofType: "png") ?? Bundle.main.path(forResource: "MenuBarIcon@2x", ofType: "png"),
           let img = NSImage(contentsOfFile: path) {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }

        if let img = NSImage(named: "MenuBarIcon") {
            img.size = NSSize(width: 18, height: 18)
            img.isTemplate = true
            return img
        }

        if let sfImage = NSImage(systemSymbolName: "arrow.down.circle.fill", accessibilityDescription: "SutraKey") {
            sfImage.isTemplate = true
            return sfImage
        }

        return nil
    }

    private func updateStatusItemDisplay() {
        guard allowsSystemStatusItem, let item = statusItem, let button = item.button else { return }

        // Load custom template image if available
        if let image = loadMenuBarIcon() {
            button.image = image
            button.imagePosition = .imageLeading
        }

        if let highestProgressJob = activeTasks.max(by: { $0.progress < $1.progress }) {
            if highestProgressJob.progress <= 0.05 {
                button.title = " Connecting..."
            } else {
                let percent = Int(highestProgressJob.progress * 100)
                button.title = " \(percent)%"
            }
        } else {
            button.title = ""
        }
    }

    @objc public func statusItemClicked() {
        guard let button = statusItem?.button else { return }

        // Handle right-click context menu (right-click or Control + left-click)
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp ||
            (NSApp.currentEvent?.type == .leftMouseUp && NSApp.currentEvent?.modifierFlags.contains(.control) == true)

        if isRightClick {
            if let pop = popover, pop.isShown {
                pop.performClose(nil)
            }

            let menu = createContextMenu()
            statusItem?.menu = menu
            button.performClick(nil)
            return
        }

        // Left-click: Open SwiftUI Popover
        if let pop = popover, pop.isShown {
            pop.performClose(nil)
            return
        }

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentSize = NSSize(width: 340, height: 320)

        let contentView = ProgressPopoverView(
            controller: self,
            onCancelJob: { jobId in
                Task {
                    await ConversionTaskActor.shared.cancelJob(id: jobId)
                }
            }
        )

        pop.contentViewController = NSHostingController(rootView: contentView)
        self.popover = pop
        pop.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    /// Creates and configures the right-click context menu with explicit targets and enabled states.
    public func createContextMenu() -> NSMenu {
        let menu = NSMenu(title: "SutraKey")
        menu.autoenablesItems = false
        menu.delegate = self

        let isEnabled = PreferencesManager.shared.shortcutsEnabled
        let toggleItem = NSMenuItem(
            title: isEnabled ? "Shortcuts: Active (⌘⇧0 to pause)" : "Shortcuts: Paused (⌘⇧0 to resume)",
            action: #selector(toggleShortcuts(_:)),
            keyEquivalent: ""
        )
        toggleItem.target = self
        toggleItem.isEnabled = true
        toggleItem.state = isEnabled ? .on : .off
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings(_:)), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)

        let updatesItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates(_:)), keyEquivalent: "u")
        updatesItem.target = self
        updatesItem.isEnabled = true
        menu.addItem(updatesItem)

        let downloadsItem = NSMenuItem(title: "Open Downloads Folder", action: #selector(openDownloadsFolder(_:)), keyEquivalent: "o")
        downloadsItem.target = self
        downloadsItem.isEnabled = true
        menu.addItem(downloadsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit SutraKey", action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)

        return menu
    }

    @objc public func toggleShortcuts(_ sender: Any? = nil) {
        PreferencesManager.shared.toggleShortcuts()
    }

    @objc public func openSettings(_ sender: Any? = nil) {
        SettingsWindowController.shared.showSettings()
    }

    @objc public func checkForUpdates(_ sender: Any? = nil) {
        SettingsWindowController.shared.showSettings()
        Task {
            await UpdateManager.shared.checkForUpdates()
        }
    }

    @objc public func openDownloadsFolder(_ sender: Any? = nil) {
        let dir = PreferencesManager.shared.downloadDirectory
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dir.path)
    }

    @objc public func quitApp(_ sender: Any? = nil) {
        NSApp.terminate(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}

// MARK: - NSMenuDelegate & NSMenuItemValidation

extension EphemeralStatusBarController: NSMenuDelegate, NSMenuItemValidation {
    public func menuDidClose(_ menu: NSMenu) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem?.menu = nil
        }
    }

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
}
