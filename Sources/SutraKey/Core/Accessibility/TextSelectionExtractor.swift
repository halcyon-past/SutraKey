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

        // 2. Secondary: Transient clipboard snapshot of current selection
        // Synthesizes a clean Cmd+C, reads the freshly copied selection, and restores the original clipboard.
        if let clipboardText = extractViaTransientClipboard(), !clipboardText.isEmpty {
            if let url = URLSanitizer.extractURL(from: clipboardText) {
                Logger.accessibility.info("Extracted URL via active selection transient copy: \(url.absoluteString)")
                return url
            }
        }

        // 3. Fallback: Active clipboard content (ONLY if explicitly allowed, e.g. via explicit hotkey)
        if allowClipboardFallback, let directText = NSPasteboard.general.string(forType: .string), !directText.isEmpty {
            if let url = URLSanitizer.extractURL(from: directText) {
                Logger.accessibility.info("Extracted URL from active pasteboard fallback: \(url.absoluteString)")
                return url
            }
        }

        return nil
    }

    /// Queries the focused UI element and its hierarchy for selected text via the Accessibility API.
    private static func extractViaAccessibility() -> String? {
        let systemWide = AXUIElementCreateSystemWide()

        // Attempt 1: System-wide focused element directly
        var focusedElemObj: AnyObject?
        if AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElemObj) == .success,
           let focusedElem = focusedElemObj {
            let element = focusedElem as! AXUIElement
            if let text = checkSelectedText(in: element) {
                return text
            }
        }

        // Attempt 2: Focused application -> focused element
        var focusedAppObj: AnyObject?
        if AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedAppObj) == .success,
           let focusedApp = focusedAppObj {
            let appElement = focusedApp as! AXUIElement

            var appFocusedElemObj: AnyObject?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &appFocusedElemObj) == .success,
               let appFocusedElem = appFocusedElemObj {
                let element = appFocusedElem as! AXUIElement
                if let text = checkSelectedText(in: element) {
                    return text
                }
            }
        }

        return nil
    }

    /// Checks an element and up to 4 parent containers for selected text.
    private static func checkSelectedText(in element: AXUIElement) -> String? {
        var current: AXUIElement? = element
        var depth = 0

        while let elem = current, depth < 5 {
            var selectedValue: AnyObject?
            if AXUIElementCopyAttributeValue(elem, kAXSelectedTextAttribute as CFString, &selectedValue) == .success,
               let selectedString = selectedValue as? String {
                let trimmed = selectedString.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
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
    /// verifies that new text was actually copied, and restores original clipboard.
    @MainActor
    private static func extractViaTransientClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        let originalChangeCount = pasteboard.changeCount

        // Backup existing clipboard items
        let originalItems = pasteboard.pasteboardItems?.map { item -> (NSPasteboard.PasteboardType, Data) in
            for type in item.types {
                if let data = item.data(forType: type) {
                    return (type, data)
                }
            }
            return (NSPasteboard.PasteboardType.string, Data())
        }

        // Synthesize Cmd+C using private event source to avoid physical Shift modifier leakage
        guard let source = CGEventSource(stateID: .privateState) else {
            return nil
        }

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true) // 0x08 = 'C'
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        // Poll pasteboard for changes from the active selection (up to 120ms in 15ms increments)
        var didChange = false
        for _ in 0..<8 {
            usleep(15_000) // 15ms
            if pasteboard.changeCount != originalChangeCount {
                didChange = true
                break
            }
        }

        var extractedText: String?
        if didChange {
            extractedText = pasteboard.string(forType: .string)
        }

        // Restore original clipboard contents so user's clipboard is preserved
        pasteboard.clearContents()
        if let original = originalItems, !original.isEmpty {
            for (type, data) in original {
                pasteboard.setData(data, forType: type)
            }
        }

        return extractedText?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
