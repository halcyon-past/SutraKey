import AppKit
import Carbon
import Combine
import Foundation
import os
import SwiftUI

/// Centralized, reference-type coordinator for recording keyboard shortcuts in SettingsView.
/// Eliminates struct @State event monitor leaks by managing a deterministic lifecycle.
@MainActor
public final class ShortcutRecorderCoordinator: ObservableObject {
    public static let shared = ShortcutRecorderCoordinator()

    @Published public var isRecording: Bool = false
    @Published public var errorMessage: String? = nil

    private var localMonitor: Any?

    public init() {}

    /// Starts recording a new shortcut by installing a local key monitor.
    public func startRecording() {
        guard !isRecording else { return }
        stopRecording()

        isRecording = true
        errorMessage = nil

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self = self else { return event }
            return self.handleKeyDownEvent(event)
        }
    }

    /// Stops recording and detaches the local key monitor.
    public func stopRecording() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        isRecording = false
    }

    /// Evaluates a key-down event during recording.
    private func handleKeyDownEvent(_ event: NSEvent) -> NSEvent? {
        // 1. Esc key cancels recording cleanly
        if event.keyCode == 53 { // kVK_Escape
            stopRecording()
            return nil
        }

        // 2. Extract modifiers (Command, Option, Control, Shift)
        let flags = event.modifierFlags.intersection([.command, .option, .control, .shift])

        // Strictly reject hotkeys without modifier keys!
        if flags.isEmpty {
            self.errorMessage = "Shortcut must include at least one modifier key (⌘, ⌥, ⌃, or ⇧)."
            return nil
        }

        let keyCode = UInt32(event.keyCode)

        // Convert NSEvent.ModifierFlags to Carbon modifier bits
        var carbonModifiers: UInt32 = 0
        if flags.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if flags.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if flags.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }

        // Save to Preferences
        PreferencesManager.shared.setCustomShortcut(keyCode: keyCode, modifiers: carbonModifiers)

        // Re-register in GlobalHotKeyManager
        GlobalHotKeyManager.shared.reloadHotKeys()

        stopRecording()
        return nil
    }

    /// Formats a key code and Carbon modifiers into a human-readable string (e.g. "⌘⇧S", "⌥ Space").
    public static func stringRepresentation(keyCode: UInt32, modifiers: UInt32) -> String {
        var result = ""
        if (modifiers & UInt32(controlKey)) != 0 { result += "⌃" }
        if (modifiers & UInt32(optionKey)) != 0 { result += "⌥" }
        if (modifiers & UInt32(shiftKey)) != 0 { result += "⇧" }
        if (modifiers & UInt32(cmdKey)) != 0 { result += "⌘" }

        result += keyString(for: keyCode)
        return result
    }

    public static func keyString(for keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_ForwardDelete: return "⌦"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_Minus: return "-"
        case kVK_ANSI_Equal: return "="
        case kVK_ANSI_LeftBracket: return "["
        case kVK_ANSI_RightBracket: return "]"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Semicolon: return ";"
        case kVK_ANSI_Quote: return "'"
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_Grave: return "`"
        default:
            return "Key(\(keyCode))"
        }
    }
}
