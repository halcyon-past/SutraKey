import AppKit
import Foundation
import os
import SwiftUI

/// Main AppKit Application Delegate coordinating core engine services and background loops.
@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.app.info("SutraKey launching. Initializing background services...")

        // Prompt accessibility permissions prompt if needed
        checkAccessibilityPermissions()

        // Wire conversion engine callbacks to Ephemeral Status Bar and Toast HUD
        Task {
            await ConversionTaskActor.shared.setHandlers(
                onStarted: { job in
                    EphemeralStatusBarController.shared.taskDidStart(job)
                    SutraToastController.shared.showTaskStarted(job)
                },
                onUpdated: { job in
                    EphemeralStatusBarController.shared.taskDidUpdate(job)
                },
                onCompleted: { job in
                    EphemeralStatusBarController.shared.taskDidComplete(job)
                    if let fileURL = job.destinationFileURL {
                        SutraToastController.shared.showTaskCompleted(job, fileURL: fileURL)
                    }
                },
                onFailed: { job, errorMsg in
                    EphemeralStatusBarController.shared.taskDidFail(job, error: errorMsg)
                    SutraToastController.shared.showTaskFailed(job, message: errorMsg)
                }
            )
        }

        // Start global keyboard/mouse monitor
        ShiftSelectionMonitor.shared.startMonitoring()

        Logger.app.info("SutraKey running invisibly in background. Ready for Shift+Select actions.")
    }

    public func applicationWillTerminate(_ notification: Notification) {
        ShiftSelectionMonitor.shared.stopMonitoring()
    }

    private func checkAccessibilityPermissions() {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            Logger.accessibility.warning("SutraKey requires macOS Accessibility permissions to read selected text.")
        }
    }
}
