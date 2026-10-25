import AppKit
import Foundation
import os
import SwiftUI
import UserNotifications

/// Controls the floating frosted glass HUD panel in the top-right corner beneath the menu bar
/// and coordinates interactive macOS system notifications with quick action responses.
@MainActor
public final class SutraToastController: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = SutraToastController()

    public static let completedCategory = "cloud.aritro.sutrakey.task.completed"
    public static let actionOpen = "ACTION_OPEN"
    public static let actionQuickLook = "ACTION_QUICK_LOOK"
    public static let actionCopyFile = "ACTION_COPY_FILE"
    public static let actionDelete = "ACTION_DELETE"

    private var toastPanel: NSPanel?
    private var dismissTimer: Timer?

    public override init() {
        super.init()
        setupSystemNotificationPermissions()
    }

    private var isRunningInApp: Bool {
        guard let bundleId = Bundle.main.bundleIdentifier, !bundleId.isEmpty else { return false }
        return Bundle.main.bundleURL.pathExtension == "app"
    }

    private func setupSystemNotificationPermissions() {
        guard isRunningInApp else { return }

        let center = UNUserNotificationCenter.current()
        center.delegate = self

        // Define interactive action buttons for completed downloads
        let openAction = UNNotificationAction(
            identifier: Self.actionOpen,
            title: "Open",
            options: [.foreground]
        )

        let quickLookAction = UNNotificationAction(
            identifier: Self.actionQuickLook,
            title: "Quick Look",
            options: [.foreground]
        )

        let copyFileAction = UNNotificationAction(
            identifier: Self.actionCopyFile,
            title: "Copy File",
            options: []
        )

        let deleteAction = UNNotificationAction(
            identifier: Self.actionDelete,
            title: "Delete",
            options: [.destructive]
        )

        let completedCategory = UNNotificationCategory(
            identifier: Self.completedCategory,
            actions: [openAction, quickLookAction, copyFileAction, deleteAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([completedCategory])
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Displays toast HUD and native notification for task initiation.
    public func showTaskStarted(_ job: ConversionJob) {
        showToast(type: .start(job: job))
        postSystemNotification(
            title: "SutraKey Started",
            subtitle: "Converting to \(job.action.title)",
            body: job.domain
        )
    }

    /// Displays toast HUD and interactive notification for successful task completion.
    public func showTaskCompleted(_ job: ConversionJob, fileURL: URL) {
        showToast(type: .success(job: job, fileURL: fileURL))
        postSystemNotification(
            title: "Saved to Downloads",
            subtitle: job.action.shortBadge,
            body: fileURL.lastPathComponent,
            categoryIdentifier: Self.completedCategory,
            userInfo: ["filePath": fileURL.path]
        )
    }

    /// Displays toast HUD and native notification for failure.
    public func showTaskFailed(_ job: ConversionJob, message: String) {
        showToast(type: .failure(job: job, message: message))
        postSystemNotification(
            title: "Conversion Failed",
            subtitle: job.action.title,
            body: message
        )
    }

    /// Displays an informational toast HUD notice.
    public func showNotice(
        title: String,
        message: String,
        systemImage: String = "info.circle.fill",
        actionTitle: String? = nil,
        action: (@MainActor () -> Void)? = nil
    ) {
        showToast(type: .notice(title: title, message: message, systemImage: systemImage, actionTitle: actionTitle, action: action))
    }

    // MARK: - Floating Panel Management

    private func showToast(type: ToastType) {
        dismissToast()

        guard isRunningInApp, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelWidth: CGFloat = 340.0
        let panelHeight: CGFloat = 90.0
        let margin: CGFloat = 16.0

        let rect = NSRect(
            x: screenFrame.maxX - panelWidth - margin,
            y: screenFrame.maxY - panelHeight - margin,
            width: panelWidth,
            height: panelHeight
        )

        let panel = NSPanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.isOpaque = false
        panel.backgroundColor = NSColor.clear
        panel.level = NSWindow.Level.floating
        panel.collectionBehavior = [NSWindow.CollectionBehavior.canJoinAllSpaces, NSWindow.CollectionBehavior.fullScreenAuxiliary]
        panel.hasShadow = false
        panel.ignoresMouseEvents = false

        let toastView = SutraToastView(type: type) { [weak self] in
            self?.dismissToast()
        }

        panel.contentView = NSHostingView(rootView: toastView)
        self.toastPanel = panel

        panel.orderFrontRegardless()

        // Auto-dismiss after 3.5 seconds
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.dismissToast()
            }
        }
    }

    public func dismissToast() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        toastPanel?.orderOut(nil)
        toastPanel = nil
    }

    // MARK: - Native Notifications

    private func postSystemNotification(
        title: String,
        subtitle: String,
        body: String,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any] = [:]
    ) {
        guard isRunningInApp else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default
        if let categoryIdentifier = categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        content.userInfo = userInfo

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Logger.toast.error("Failed to post system notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        guard let path = userInfo["filePath"] as? String else {
            completionHandler()
            return
        }

        let fileURL = URL(fileURLWithPath: path)
        let actionId = response.actionIdentifier

        Task { @MainActor in
            switch actionId {
            case Self.actionOpen:
                NSWorkspace.shared.open(fileURL)

            case Self.actionQuickLook, UNNotificationDefaultActionIdentifier:
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])

            case Self.actionCopyFile:
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.writeObjects([fileURL as NSURL])
                SutraToastController.shared.showNotice(
                    title: "Copied to Clipboard",
                    message: fileURL.lastPathComponent,
                    systemImage: "doc.on.doc.fill"
                )

            case Self.actionDelete:
                NSWorkspace.shared.recycle([fileURL]) { _, error in
                    Task { @MainActor in
                        if error == nil {
                            SutraToastController.shared.showNotice(
                                title: "Moved to Trash",
                                message: fileURL.lastPathComponent,
                                systemImage: "trash.fill"
                            )
                        }
                    }
                }

            default:
                break
            }
        }

        completionHandler()
    }
}
