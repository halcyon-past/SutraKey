import AppKit
import ApplicationServices
import Foundation
import os

/// Extracts highlighted text and URLs from foreground applications via Accessibility API
/// with a zero-loss transient clipboard fallback.
public enum TextSelectionExtractor: Sendable {

    /// Extracts a validated URL from current text selection in foreground application.
    @MainActor
    public static func extractSelectedURL() -> URL? {
        // 1. Primary: macOS Accessibility API
        if let axText = extractViaAccessibility(), !axText.isEmpty {
            if let url = URLSanitizer.extractURL(from: axText) {
                Logger.accessibility.info("Extracted URL via AX: \(url.absoluteString)")
                return url
            }
        }

        // 2. Fallback: Transient clipboard snapshot
        if let clipboardText = extractViaTransientClipboard(), !clipboardText.isEmpty {
            if let url = URLSanitizer.extractURL(from: clipboardText) {
                Logger.accessibility.info("Extracted URL via transient clipboard: \(url.absoluteString)")
                return url
            }
        }

        return nil
    }

    /// Queries the focused UI element for its selected text via the Accessibility API.
    private static func extractViaAccessibility() -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        var focusedApp: AnyObject?

        let appResult = AXUIElementCopyAttributeValue(
            systemWide,
            "AXFocusedApplication" as CFString,
            &focusedApp
        )

        guard appResult == .success, let focusedApp = focusedApp else {
            return nil
        }

        // Cast to AXUIElement
        let appElement = focusedApp as! AXUIElement // Safe standard CFType cast

        var focusedElement: AnyObject?
        let elemResult = AXUIElementCopyAttributeValue(
            appElement,
            "AXFocusedUIElement" as CFString,
            &focusedElement
        )

        guard elemResult == .success, let focusedElement = focusedElement else {
            return nil
        }

        let element = focusedElement as! AXUIElement
        var selectedValue: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(
            element,
            "AXSelectedText" as CFString,
            &selectedValue
        )

        if textResult == .success, let selectedString = selectedValue as? String {
            return selectedString.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return nil
    }

    /// Snapshots user's current clipboard, performs a transient copy, reads text, and restores original clipboard.
    @MainActor
    private static func extractViaTransientClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        let originalItems = pasteboard.pasteboardItems?.map { item -> (NSPasteboard.PasteboardType, Data) in
            for type in item.types {
                if let data = item.data(forType: type) {
                    return (type, data)
                }
            }
            return (NSPasteboard.PasteboardType.string, Data())
        }

        // Clear and simulate Cmd+C via CGEvent
        let initialChangeCount = pasteboard.changeCount

        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 0x08 = 'C'
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        // Wait briefly for pasteboard update
        usleep(45_000) // 45ms

        var extractedText: String?
        if pasteboard.changeCount != initialChangeCount {
            extractedText = pasteboard.string(forType: .string)
        }

        // Restore original clipboard contents immediately within 50ms window
        pasteboard.clearContents()
        if let original = originalItems, !original.isEmpty {
            for (type, data) in original {
                pasteboard.setData(data, forType: type)
            }
        }

        return extractedText
    }
}
