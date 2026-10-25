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

        // Initialize status bar presence according to user preferences
        EphemeralStatusBarController.shared.updateVisibility()

        // Start global keyboard/mouse monitor (Shift+Select, Shift+Click, Double-tap Shift)
        ShiftSelectionMonitor.shared.startMonitoring()

        // Register Apple Event handler for sutrakey:// custom URL scheme
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        // Register system-wide Carbon hotkeys (Cmd+Shift+S, Option+Shift+S)
        GlobalHotKeyManager.shared.onTrigger = {
            ShiftSelectionMonitor.shared.attemptRadialTrigger(at: NSEvent.mouseLocation, allowClipboardFallback: true)
        }
        GlobalHotKeyManager.shared.registerHotKeys()

        // Optional auto-update check on launch
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if PreferencesManager.shared.autoCheckUpdates {
                await UpdateManager.shared.checkForUpdates()
            }
        }

        Logger.app.info("SutraKey running invisibly in background. Ready for Shift+Select or Cmd+Shift+S.")

        // First launch or Permission Relaunch visual cue:
        // If it is the first launch or accessibility permissions are not yet granted,
        // present the Settings window so the user gets immediate visual feedback and setup guidance.
        let hasLaunchedKey = "cloud.aritro.sutrakey.hasLaunchedBefore"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasLaunchedKey)
        if isFirstLaunch || !AXIsProcessTrusted() {
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            Logger.app.info("Presenting Settings window for initial setup or permissions guidance.")
            DispatchQueue.main.async {
                SettingsWindowController.shared.showSettings()
            }
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        ShiftSelectionMonitor.shared.stopMonitoring()
        GlobalHotKeyManager.shared.unregisterHotKeys()
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Logger.app.info("Application reopened via Finder/Spotlight/Launchpad. Presenting Settings window.")
        SettingsWindowController.shared.showSettings()
        return true
    }

    public func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        SettingsWindowController.shared.showSettings()
        return true
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            SutraURLRouter.shared.handle(url: url)
        }
    }

    @objc private func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else { return }
        SutraURLRouter.shared.handle(url: url)
    }

    private func checkAccessibilityPermissions() {
        let isTrusted = AXIsProcessTrusted()
        if isTrusted {
            Logger.accessibility.info("macOS Accessibility permissions verified.")
        } else {
            Logger.accessibility.info("Accessibility permissions not granted. Checking initial prompt.")
            let hasPromptedKey = "cloud.aritro.sutrakey.hasPromptedAccessibility"
            if !UserDefaults.standard.bool(forKey: hasPromptedKey) {
                UserDefaults.standard.set(true, forKey: hasPromptedKey)
                let options = ["AXTrustedCheckOptionPrompt" as CFString: true] as CFDictionary
                _ = AXIsProcessTrustedWithOptions(options)
            }
        }
    }
}
