import AppKit
import Foundation
import os
import SwiftUI

/// Controls the ephemeral NSStatusItem in the macOS Menu Bar.
/// Appears strictly while active conversion tasks are running and vanishes when idle.
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

    /// Notification hook fired for testing and HUD toasts.
    public var onTaskStartedNotification: ((ConversionJob) -> Void)?
    public var onTaskCompletedNotification: ((ConversionJob) -> Void)?
    public var onTaskFailedNotification: ((ConversionJob, String) -> Void)?

    public override init() {
        super.init()
        // Strictly hidden on initial launch
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

        dismissTimer?.invalidate()
        if completionGracePeriodSeconds <= 0.0 {
            self.hideStatusItem()
        } else {
            dismissTimer = Timer.scheduledTimer(withTimeInterval: completionGracePeriodSeconds, repeats: false) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self, self.activeTasks.isEmpty else { return }
                    self.hideStatusItem()
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

    private func updateVisibility() {
        if !activeTasks.isEmpty && !isIconVisible {
            isIconVisible = true
            setupStatusItemIfNeeded()
        }
    }

    private func setupStatusItemIfNeeded() {
        guard allowsSystemStatusItem else { return }
        guard statusItem == nil else {
            statusItem?.isVisible = true
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
    }

    private func updateStatusItemDisplay() {
        guard allowsSystemStatusItem, let item = statusItem, let button = item.button else { return }

        // Load custom template image if available
        if let image = NSImage(named: "MenuBarIcon") ?? NSImage(systemSymbolName: "arrow.down.circle.fill", accessibilityDescription: "SutraKey") {
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeading
        }

        if let highestProgressJob = activeTasks.max(by: { $0.progress < $1.progress }) {
            let percent = Int(highestProgressJob.progress * 100)
            button.title = " \(percent)%"
        } else {
            button.title = ""
        }
    }

    @objc private func statusItemClicked() {
        guard let button = statusItem?.button else { return }

        if let pop = popover, pop.isShown {
            pop.performClose(nil)
            return
        }

        let pop = NSPopover()
        pop.behavior = .transient
        pop.contentSize = NSSize(width: 320, height: 280)

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
}
