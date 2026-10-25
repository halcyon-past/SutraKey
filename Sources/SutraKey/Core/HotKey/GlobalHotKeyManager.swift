import AppKit
import Carbon
import Foundation
import os

/// Manages system-wide Carbon hotkeys that work globally across macOS without requiring Accessibility permissions.
@MainActor
public final class GlobalHotKeyManager: NSObject {
    public static let shared = GlobalHotKeyManager()

    private let lock = NSLock()
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandler: EventHandlerRef?

    public var onTrigger: (@MainActor () -> Void)?
    public var onToggleShortcuts: (@MainActor () -> Void)?

    public override init() {
        super.init()
    }

    /// Registers global shortcut keys (Custom Shortcut, Option+Shift+S, Cmd+Shift+0).
    public func registerHotKeys() {
        lock.lock()
        defer { lock.unlock() }

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
                guard let event = event else { return noErr }
                var hotKeyID = EventHotKeyID()
                let paramStatus = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                let id = (paramStatus == noErr) ? hotKeyID.id : 1
                Task { @MainActor in
                    GlobalHotKeyManager.shared.handleHotKeyPressed(id: id)
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

        // 2. Register Primary HotKey (Configured by user or default Cmd + Shift + S)
        let primaryCode = PreferencesManager.shared.customHotKeyCode
        let primaryMods = PreferencesManager.shared.customHotKeyModifiers

        registerKey(
            keyCode: primaryCode,
            modifiers: primaryMods,
            id: 1,
            target: target
        )

        // 3. Register Option + Shift + S as secondary fallback if not already the primary
        let optionShiftMods = UInt32(optionKey | shiftKey)
        let sKeyCode = UInt32(kVK_ANSI_S)
        if primaryCode != sKeyCode || primaryMods != optionShiftMods {
            registerKey(
                keyCode: sKeyCode,
                modifiers: optionShiftMods,
                id: 2,
                target: target
            )
        }

        // 4. Register Cmd + Shift + 0 (Toggle Shortcuts)
        registerKey(
            keyCode: UInt32(kVK_ANSI_0),
            modifiers: UInt32(cmdKey | shiftKey),
            id: 3,
            target: target
        )

        // 5. Register Option + Shift + 0 (Toggle Shortcuts fallback)
        registerKey(
            keyCode: UInt32(kVK_ANSI_0),
            modifiers: UInt32(optionKey | shiftKey),
            id: 4,
            target: target
        )

        Logger.events.info("GlobalHotKeyManager successfully registered shortcuts.")
    }

    /// Reloads hotkey registrations dynamically after preferences change.
    public func reloadHotKeys() {
        unregisterHotKeys()
        registerHotKeys()
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

    private func handleHotKeyPressed(id: UInt32) {
        if id == 3 || id == 4 {
            Logger.events.info("Toggle shortcuts shortcut key pressed (id: \(id)). Toggling shortcuts...")
            PreferencesManager.shared.toggleShortcuts()
            onToggleShortcuts?()
            return
        }

        guard PreferencesManager.shared.shortcutsEnabled else {
            Logger.events.info("Global shortcut key pressed (id: \(id)), but shortcuts are currently disabled in Preferences.")
            return
        }

        Logger.events.info("Global shortcut key pressed. Invoking trigger...")
        onTrigger?()
    }

    /// Unregisters all hotkeys.
    public func unregisterHotKeys() {
        lock.lock()
        defer { lock.unlock() }

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
