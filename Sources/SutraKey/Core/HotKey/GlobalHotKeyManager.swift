import AppKit
import Carbon
import Foundation
import os

/// Manages system-wide Carbon hotkeys that work globally across macOS without requiring Accessibility permissions.
@MainActor
public final class GlobalHotKeyManager: NSObject {
    public static let shared = GlobalHotKeyManager()

    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandler: EventHandlerRef?

    public var onTrigger: (@MainActor () -> Void)?

    public override init() {
        super.init()
    }

    /// Registers global shortcut keys (Cmd+Shift+S, Option+Shift+S).
    public func registerHotKeys() {
        guard hotKeyRefs.isEmpty else { return }

        // 1. Install Carbon event handler on the system Event Dispatcher Target
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let target = GetEventDispatcherTarget() ?? GetApplicationEventTarget()

        let status = InstallEventHandler(
            target,
            { (_, event, _) -> OSStatus in
                Task { @MainActor in
                    GlobalHotKeyManager.shared.handleHotKeyPressed()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        if status != noErr {
            Logger.events.error("Failed to install Carbon event handler: \(status)")
            return
        }

        // 2. Register Cmd + Shift + S
        registerKey(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(cmdKey | shiftKey),
            id: 1,
            target: target
        )

        // 3. Register Option + Shift + S
        registerKey(
            keyCode: UInt32(kVK_ANSI_S),
            modifiers: UInt32(optionKey | shiftKey),
            id: 2,
            target: target
        )

        Logger.events.info("GlobalHotKeyManager successfully registered Cmd+Shift+S and Option+Shift+S shortcuts.")
    }

    private func registerKey(keyCode: UInt32, modifiers: UInt32, id: UInt32, target: EventTargetRef?) {
        let hotKeyID = EventHotKeyID(signature: 0x53555452, id: id) // 'SUTR'
        var hotKeyRef: EventHotKeyRef?
        let err = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            target,
            0,
            &hotKeyRef
        )
        if err == noErr, let ref = hotKeyRef {
            hotKeyRefs.append(ref)
        } else {
            Logger.events.error("Failed to register hotkey \(id): \(err)")
        }
    }

    private func handleHotKeyPressed() {
        Logger.events.info("Global shortcut key pressed. Invoking trigger...")
        onTrigger?()
    }

    /// Unregisters all hotkeys.
    public func unregisterHotKeys() {
        for ref in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()

        if let handler = eventHandler {
            RemoveEventHandler(handler)
            eventHandler = nil
        }
    }
}
