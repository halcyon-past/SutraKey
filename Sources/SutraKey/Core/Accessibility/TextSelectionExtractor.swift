import AppKit
import ApplicationServices
import Foundation
import os

/// Extracts highlighted text and URLs from foreground applications via Accessibility API
/// with a zero-loss transient clipboard fallback.
public enum TextSelectionExtractor: Sendable {

    /// Extracts a validated URL from current text selection in foreground application.
    /// - Parameter allowClipboardFallback: If false, strictly requires an active text selection and never falls back to old clipboard contents.
    @MainActor
    public static func extractSelectedURL(allowClipboardFallback: Bool = false) -> URL? {
        // 1. Primary: macOS Accessibility API (reads current highlight without touching clipboard)
        if let axText = extractViaAccessibility(), !axText.isEmpty {
            if let url = URLSanitizer.extractURL(from: axText) {
                Logger.accessibility.info("Extracted URL via AX selection: \(url.absoluteString)")
                return url
            }
        }

        // 2. Secondary: Active selection transient copy (synthesizes Cmd+C directly to target application PID)
        // Works in Chromium (Brave, Chrome, Edge, Arc), web apps, electron, and custom text engines.
        if let clipboardText = extractViaTransientClipboard(), !clipboardText.isEmpty {
            if let url = URLSanitizer.extractURL(from: clipboardText) {
                Logger.accessibility.info("Extracted URL via active selection transient copy: \(url.absoluteString)")
                return url
            }
        }

        // 3. Tertiary: Frontmost Browser Active Tab URL (Brave, Chrome, Safari, Arc, Edge, etc.)
        // When no specific text is highlighted on screen, but user is viewing a media page in their browser.
        if let browserText = extractFromFrontmostBrowser(), !browserText.isEmpty {
            if let url = URLSanitizer.extractURL(from: browserText) {
                Logger.accessibility.info("Extracted URL from frontmost browser active tab: \(url.absoluteString)")
                return url
            }
        }

        // 4. Fallback: Active clipboard content (ONLY if explicitly allowed, e.g. via explicit hotkey)
        if allowClipboardFallback, let directText = NSPasteboard.general.string(forType: .string), !directText.isEmpty {
            if let url = URLSanitizer.extractURL(from: directText) {
                Logger.accessibility.info("Extracted URL from active pasteboard fallback: \(url.absoluteString)")
                return url
            }
        }

        return nil
    }

    /// Retrieves the URL of the active tab if the frontmost application is a supported browser.
    @MainActor
    public static func extractFromFrontmostBrowser() -> String? {
        let supportedBrowserBundleIDs = [
            "com.brave.Browser",
            "com.google.Chrome",
            "com.google.Chrome.canary",
            "com.apple.Safari",
            "com.apple.SafariTechnologyPreview",
            "company.thebrowser.Browser",
            "com.microsoft.edgemac",
            "com.vivaldi.Vivaldi",
            "com.kagi.kagimacOS"
        ]

        var targetBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        if targetBundleID == nil || !supportedBrowserBundleIDs.contains(targetBundleID!) {
            // Find running browser that is active or frontmost
            if let activeBrowser = NSWorkspace.shared.runningApplications.first(where: { app in
                guard let bid = app.bundleIdentifier else { return false }
                return supportedBrowserBundleIDs.contains(bid) && app.isActive
            }) {
                targetBundleID = activeBrowser.bundleIdentifier
            } else {
                for bid in supportedBrowserBundleIDs {
                    if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bid).first, !app.isHidden {
                        targetBundleID = bid
                        break
                    }
                }
            }
        }

        guard let bundleID = targetBundleID else { return nil }

        let scriptSource: String
        switch bundleID {
        case "com.brave.Browser":
            scriptSource = "tell application \"Brave Browser\" to get URL of active tab of front window"
        case "com.google.Chrome", "com.google.Chrome.canary":
            scriptSource = "tell application \"Google Chrome\" to get URL of active tab of front window"
        case "com.apple.Safari", "com.apple.SafariTechnologyPreview":
            scriptSource = "tell application \"Safari\" to get URL of front document"
        case "company.thebrowser.Browser":
            scriptSource = "tell application \"Arc\" to get URL of active tab of front window"
        case "com.microsoft.edgemac":
            scriptSource = "tell application \"Microsoft Edge\" to get URL of active tab of front window"
        case "com.vivaldi.Vivaldi":
            scriptSource = "tell application \"Vivaldi\" to get URL of active tab of front window"
        case "com.kagi.kagimacOS":
            scriptSource = "tell application \"Orion\" to get URL of front document"
        default:
            return nil
        }

        var error: NSDictionary?
        let appleScript = NSAppleScript(source: scriptSource)
        if let result = appleScript?.executeAndReturnError(&error),
           let urlString = result.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
           !urlString.isEmpty {
            return urlString
        } else if let err = error {
            Logger.accessibility.warning("Browser tab AppleScript returned error: \(err.description)")
        }

        return nil
    }

    /// Queries the focused UI element and its hierarchy for selected text via the Accessibility API.
    private static func extractViaAccessibility() -> String? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)

        // Priming: Chromium-based browsers (Brave, Chrome, Edge, Arc) only enable AX when requested
        AXUIElementSetAttributeValue(appElement, "AXEnhancedUserInterface" as CFString, kCFBooleanTrue)
        AXUIElementSetAttributeValue(appElement, "AXManualAccessibility" as CFString, kCFBooleanTrue)

        var focusedElemObj: AnyObject?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElemObj) == .success,
           let focusedElem = focusedElemObj {
            let element = focusedElem as! AXUIElement
            if let text = checkSelectedText(in: element) {
                return text
            }
        }

        // Secondary check: System-wide focused element
        let systemWide = AXUIElementCreateSystemWide()
        var sysFocusedObj: AnyObject?
        if AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &sysFocusedObj) == .success,
           let sysElem = sysFocusedObj {
            let element = sysElem as! AXUIElement
            if let text = checkSelectedText(in: element) {
                return text
            }
        }

        return nil
    }

    /// Checks an element and up to 5 parent containers for selected text.
    private static func checkSelectedText(in element: AXUIElement) -> String? {
        var current: AXUIElement? = element
        var depth = 0

        while let elem = current, depth < 6 {
            var selectedValue: AnyObject?
            if AXUIElementCopyAttributeValue(elem, kAXSelectedTextAttribute as CFString, &selectedValue) == .success,
               let selectedString = selectedValue as? String {
                let trimmed = selectedString.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    return trimmed
                }
            }

            // Check value attribute (e.g. Chromium / Safari omnibox or text fields)
            var valObj: AnyObject?
            if AXUIElementCopyAttributeValue(elem, kAXValueAttribute as CFString, &valObj) == .success,
               let valString = valObj as? String {
                let trimmed = valString.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty, let _ = URLSanitizer.extractURL(from: trimmed) {
                    return trimmed
                }
            }

            // Check parameterized range attribute
            var selectedRangeValue: AnyObject?
            if AXUIElementCopyAttributeValue(elem, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue) == .success,
               let rangeVal = selectedRangeValue {
                var stringValue: AnyObject?
                if AXUIElementCopyParameterizedAttributeValue(elem, kAXStringForRangeParameterizedAttribute as CFString, rangeVal, &stringValue) == .success,
                   let rangeString = stringValue as? String {
                    let trimmed = rangeString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        return trimmed
                    }
                }
            }

            // Move up to parent element (e.g. AXWebArea in WebKit/Chromium)
            var parentObj: AnyObject?
            if AXUIElementCopyAttributeValue(elem, kAXParentAttribute as CFString, &parentObj) == .success,
               let parentElem = parentObj {
                current = (parentElem as! AXUIElement)
            } else {
                current = nil
            }
            depth += 1
        }

        return nil
    }

    /// Snapshots user's current clipboard, performs a transient copy of the active selection,
    /// verifies that a valid URL was actually copied, and restores original clipboard if invalid.
    @MainActor
    private static func extractViaTransientClipboard() -> String? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let pasteboard = NSPasteboard.general
        let originalChangeCount = pasteboard.changeCount

        // Backup existing clipboard items so we preserve user data
        let originalItems = pasteboard.pasteboardItems?.map { item -> (NSPasteboard.PasteboardType, Data) in
            for type in item.types {
                if let data = item.data(forType: type) {
                    return (type, data)
                }
            }
            return (NSPasteboard.PasteboardType.string, Data())
        }

        // Synthesize Cmd+C using hardware event source
        guard let source = CGEventSource(stateID: .hidSystemState) else {
            return nil
        }

        // Explicitly synthesize Shift UP for both left shift (0x38) and right shift (0x3C).
        // This is crucial: if user is holding Shift during drag selection or hotkey,
        // physical Shift would turn Cmd+C into Cmd+Shift+C (which opens DevTools in Chromium).
        let leftShiftUp = CGEvent(keyboardEventSource: source, virtualKey: 0x38, keyDown: false)
        leftShiftUp?.flags = []
        let rightShiftUp = CGEvent(keyboardEventSource: source, virtualKey: 0x3C, keyDown: false)
        rightShiftUp?.flags = []

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 0x08 = 'C'
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUp?.flags = .maskCommand

        // Post directly to target process PID to bypass HID physical modifier merging
        leftShiftUp?.postToPid(frontApp.processIdentifier)
        rightShiftUp?.postToPid(frontApp.processIdentifier)
        keyDown?.postToPid(frontApp.processIdentifier)
        keyUp?.postToPid(frontApp.processIdentifier)

        // Also post to session event tap
        leftShiftUp?.post(tap: .cgSessionEventTap)
        rightShiftUp?.post(tap: .cgSessionEventTap)
        keyDown?.post(tap: .cgSessionEventTap)
        keyUp?.post(tap: .cgSessionEventTap)

        // Poll pasteboard for changes with RunLoop pumping (up to 300ms in 15ms increments)
        var didChange = false
        let deadline = Date().addingTimeInterval(0.30)
        while Date() < deadline {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.015))
            if pasteboard.changeCount != originalChangeCount {
                didChange = true
                break
            }
        }

        var extractedText: String?
        if didChange {
            extractedText = pasteboard.string(forType: .string)
        }

        // If nothing was copied or the text does not contain a valid URL,
        // restore the user's previous clipboard contents
        let validURL = extractedText != nil ? URLSanitizer.extractURL(from: extractedText!) : nil
        if validURL == nil {
            pasteboard.clearContents()
            if let original = originalItems, !original.isEmpty {
                for (type, data) in original {
                    pasteboard.setData(data, forType: type)
                }
            }
            return nil
        }

        return extractedText?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
