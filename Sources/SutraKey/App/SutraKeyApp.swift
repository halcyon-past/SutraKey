import SwiftUI

/// Main entry point for SutraKey macOS background utility.
@main
struct SutraKeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
