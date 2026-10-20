import AppKit
import ApplicationServices
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

        // Start global keyboard/mouse monitor (Shift+Select, Shift+Click, Double-tap Shift)
        ShiftSelectionMonitor.shared.startMonitoring()

        // Register system-wide Carbon hotkeys (Cmd+Shift+S, Option+Shift+S)
        GlobalHotKeyManager.shared.onTrigger = {
            ShiftSelectionMonitor.shared.attemptRadialTrigger(at: NSEvent.mouseLocation)
        }
        GlobalHotKeyManager.shared.registerHotKeys()

        Logger.app.info("SutraKey running invisibly in background. Ready for Shift+Select or Cmd+Shift+S.")
    }

    public func applicationWillTerminate(_ notification: Notification) {
        ShiftSelectionMonitor.shared.stopMonitoring()
        GlobalHotKeyManager.shared.unregisterHotKeys()
    }

    private func checkAccessibilityPermissions() {
        let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            Logger.accessibility.warning("SutraKey requires macOS Accessibility permissions to read selected text.")
            SutraToastController.shared.showNotice(
                title: "Accessibility Required",
                message: "Please toggle SutraKey ON in System Settings > Privacy & Security > Accessibility.",
                systemImage: "hand.raised.fill",
                actionTitle: "Open Settings",
                action: {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            )
        }
    }
}
