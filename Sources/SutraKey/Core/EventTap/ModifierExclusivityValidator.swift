import AppKit
import Foundation

/// Validates that ONLY the Shift modifier key is held without modifier pollution.
public enum ModifierExclusivityValidator: Sendable {
    /// Disallowed modifier keys that invalidate the SutraKey trigger condition.
    public static let forbiddenModifiers: NSEvent.ModifierFlags = [
        .command,
        .option,
        .control,
        .capsLock
    ]

    /// Returns `true` if and only if the Shift key is pressed and NO other modifier keys are active.
    /// - Parameter flags: The raw or filtered `NSEvent.ModifierFlags`
    /// - Returns: `true` if exclusive Shift, otherwise `false`.
    public static func isShiftOnly(flags: NSEvent.ModifierFlags) -> Bool {
        let cleanFlags = flags.intersection(.deviceIndependentFlagsMask)

        // Must contain Shift
        guard cleanFlags.contains(.shift) else {
            return false
        }

        // Must not contain any forbidden modifiers (Command, Option, Control, CapsLock, Function)
        guard cleanFlags.intersection(forbiddenModifiers).isEmpty else {
            return false
        }

        return true
    }

    /// Checks if any modifier pollution is active (e.g., when radial menu is already displayed).
    /// - Parameter flags: The `NSEvent.ModifierFlags`
    /// - Returns: `true` if any conflicting modifier is held.
    public static func hasConflictingModifiers(flags: NSEvent.ModifierFlags) -> Bool {
        let cleanFlags = flags.intersection(.deviceIndependentFlagsMask)
        return !cleanFlags.intersection(forbiddenModifiers).isEmpty
    }
}
