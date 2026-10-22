import AppKit
import Foundation
import os
import SwiftUI
import UserNotifications

/// Controls the floating frosted glass HUD panel in the top-right corner beneath the menu bar.
@MainActor
public final class SutraToastController: NSObject {
    public static let shared = SutraToastController()

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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
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

    /// Displays toast HUD and native notification for successful task completion.
    public func showTaskCompleted(_ job: ConversionJob, fileURL: URL) {
        showToast(type: .success(job: job, fileURL: fileURL))
        postSystemNotification(
            title: "Saved to Downloads",
            subtitle: job.action.shortBadge,
            body: fileURL.lastPathComponent
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

    private func postSystemNotification(title: String, subtitle: String, body: String) {
        guard isRunningInApp else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default

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
}
