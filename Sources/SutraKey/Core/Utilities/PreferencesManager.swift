import AppKit
import Foundation
import os
import SwiftUI

/// Centralized preferences manager persisting user settings via UserDefaults with reactive SwiftUI state.
@MainActor
public final class PreferencesManager: ObservableObject {
    public static let shared = PreferencesManager()

    // MARK: - Keys
    private let kDownloadPath = "cloud.aritro.sutrakey.downloadPath"
    private let kKeepStatusBarVisible = "cloud.aritro.sutrakey.keepStatusBarVisible"
    private let kShortcutsEnabled = "cloud.aritro.sutrakey.shortcutsEnabled"
    private let kPreferredVideoCodec = "cloud.aritro.sutrakey.preferredVideoCodec"
    private let kPreferredAudioBitrate = "cloud.aritro.sutrakey.preferredAudioBitrate"
    private let kPlayCompletionSound = "cloud.aritro.sutrakey.playCompletionSound"
    private let kShowCompletionToast = "cloud.aritro.sutrakey.showCompletionToast"
    private let kAutoCheckUpdates = "cloud.aritro.sutrakey.autoCheckUpdates"
    private let kLastUpdateCheck = "cloud.aritro.sutrakey.lastUpdateCheck"
    private let kBrowserCookiesSource = "cloud.aritro.sutrakey.browserCookiesSource"
    private let kCustomCookiesPath = "cloud.aritro.sutrakey.customCookiesPath"
    private let kCookiesOnlyForAuthSites = "cloud.aritro.sutrakey.cookiesOnlyForAuthSites"

    // MARK: - Published Properties

    @Published public var downloadDirectory: URL {
        didSet {
            UserDefaults.standard.set(downloadDirectory.path, forKey: kDownloadPath)
            Logger.app.info("Download directory set to: \(self.downloadDirectory.path)")
        }
    }

    @Published public var keepStatusBarVisible: Bool {
        didSet {
            UserDefaults.standard.set(keepStatusBarVisible, forKey: kKeepStatusBarVisible)
            EphemeralStatusBarController.shared.updateVisibility()
        }
    }

    @Published public var shortcutsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(shortcutsEnabled, forKey: kShortcutsEnabled)
            Logger.app.info("Application shortcuts toggled to: \(self.shortcutsEnabled)")
        }
    }

    @Published public var preferredVideoCodec: String {
        didSet {
            UserDefaults.standard.set(preferredVideoCodec, forKey: kPreferredVideoCodec)
        }
    }

    @Published public var preferredAudioBitrate: String {
        didSet {
            UserDefaults.standard.set(preferredAudioBitrate, forKey: kPreferredAudioBitrate)
        }
    }

    @Published public var playCompletionSound: Bool {
        didSet {
            UserDefaults.standard.set(playCompletionSound, forKey: kPlayCompletionSound)
        }
    }

    @Published public var showCompletionToast: Bool {
        didSet {
            UserDefaults.standard.set(showCompletionToast, forKey: kShowCompletionToast)
        }
    }

    @Published public var autoCheckUpdates: Bool {
        didSet {
            UserDefaults.standard.set(autoCheckUpdates, forKey: kAutoCheckUpdates)
        }
    }

    @Published public var lastUpdateCheckDate: Date? {
        didSet {
            UserDefaults.standard.set(lastUpdateCheckDate, forKey: kLastUpdateCheck)
        }
    }

    @Published public var browserCookiesSource: String {
        didSet {
            UserDefaults.standard.set(browserCookiesSource, forKey: kBrowserCookiesSource)
        }
    }

    @Published public var customCookiesPath: String {
        didSet {
            UserDefaults.standard.set(customCookiesPath, forKey: kCustomCookiesPath)
        }
    }

    @Published public var cookiesOnlyForAuthRequiredSites: Bool {
        didSet {
            UserDefaults.standard.set(cookiesOnlyForAuthRequiredSites, forKey: kCookiesOnlyForAuthSites)
        }
    }

    // MARK: - Init

    public init() {
        // Resolve default ~/Downloads directory
        let defaultDownloads: URL = {
            if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                return downloads.standardizedFileURL
            }
            return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Downloads", isDirectory: true).standardizedFileURL
        }()

        if let savedPath = UserDefaults.standard.string(forKey: kDownloadPath), !savedPath.isEmpty {
            let candidate = URL(fileURLWithPath: savedPath, isDirectory: true)
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDir), isDir.boolValue {
                self.downloadDirectory = candidate.standardizedFileURL
            } else {
                self.downloadDirectory = defaultDownloads
            }
        } else {
            self.downloadDirectory = defaultDownloads
        }

        self.keepStatusBarVisible = UserDefaults.standard.object(forKey: kKeepStatusBarVisible) == nil ? true : UserDefaults.standard.bool(forKey: kKeepStatusBarVisible)
        self.shortcutsEnabled = UserDefaults.standard.object(forKey: kShortcutsEnabled) == nil ? true : UserDefaults.standard.bool(forKey: kShortcutsEnabled)
        self.preferredVideoCodec = UserDefaults.standard.string(forKey: kPreferredVideoCodec) ?? "h264_aac"
        self.preferredAudioBitrate = UserDefaults.standard.string(forKey: kPreferredAudioBitrate) ?? "320k"
        self.playCompletionSound = UserDefaults.standard.object(forKey: kPlayCompletionSound) == nil ? true : UserDefaults.standard.bool(forKey: kPlayCompletionSound)
        self.showCompletionToast = UserDefaults.standard.object(forKey: kShowCompletionToast) == nil ? true : UserDefaults.standard.bool(forKey: kShowCompletionToast)
        self.autoCheckUpdates = UserDefaults.standard.object(forKey: kAutoCheckUpdates) == nil ? true : UserDefaults.standard.bool(forKey: kAutoCheckUpdates)
        self.lastUpdateCheckDate = UserDefaults.standard.object(forKey: kLastUpdateCheck) as? Date

        // Default browser cookies source: auto-detect Brave or Chrome if installed, otherwise "brave"
        let defaultBrowser: String = {
            if FileManager.default.fileExists(atPath: "/Applications/Brave Browser.app") {
                return "brave"
            } else if FileManager.default.fileExists(atPath: "/Applications/Google Chrome.app") {
                return "chrome"
            }
            return "brave"
        }()
        self.browserCookiesSource = UserDefaults.standard.string(forKey: kBrowserCookiesSource) ?? defaultBrowser
        self.customCookiesPath = UserDefaults.standard.string(forKey: kCustomCookiesPath) ?? ""
        self.cookiesOnlyForAuthRequiredSites = UserDefaults.standard.object(forKey: kCookiesOnlyForAuthSites) == nil ? true : UserDefaults.standard.bool(forKey: kCookiesOnlyForAuthSites)
    }

    /// Determines whether a target URL requires authenticated browser cookies (e.g. Instagram login walls).
    public static func domainRequiresCookies(url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }
        let authHosts = [
            "instagram.com",
            "instagr.am",
            "threads.net",
            "facebook.com",
            "fb.watch",
            "patreon.com"
        ]
        return authHosts.contains { host == $0 || host.hasSuffix("." + $0) }
    }

    /// Resolves yt-dlp arguments for cookies based on user preferences.
    public func resolveCookieArguments(for url: URL? = nil) -> [String] {
        if browserCookiesSource == "custom", !customCookiesPath.isEmpty {
            return ["--cookies", customCookiesPath]
        }
        guard browserCookiesSource != "none", !browserCookiesSource.isEmpty else {
            return []
        }

        if cookiesOnlyForAuthRequiredSites {
            if let target = url, PreferencesManager.domainRequiresCookies(url: target) {
                return ["--cookies-from-browser", browserCookiesSource]
            }
            // Public platforms (YouTube, Reddit, Twitter, TikTok, etc.) do NOT receive browser cookies
            // to eliminate macOS Keychain prompts and prevent YouTube bot-detection blocks.
            return []
        } else {
            return ["--cookies-from-browser", browserCookiesSource]
        }
    }

    // MARK: - Actions

    /// Prompts user to pick a new download folder via NSOpenPanel.
    public func selectDownloadDirectory(window: NSWindow? = nil) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose Folder"
        panel.message = "Select default download destination for SutraKey"
        panel.directoryURL = downloadDirectory

        if let win = window {
            panel.beginSheetModal(for: win) { [weak self] response in
                if response == .OK, let selectedURL = panel.url {
                    self?.downloadDirectory = selectedURL.standardizedFileURL
                }
            }
        } else {
            let response = panel.runModal()
            if response == .OK, let selectedURL = panel.url {
                self.downloadDirectory = selectedURL.standardizedFileURL
            }
        }
    }

    /// Resets download directory to native ~/Downloads.
    public func resetDownloadDirectory() {
        if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            self.downloadDirectory = downloads.standardizedFileURL
        }
    }

    /// Verifies and triggers macOS Keychain authorization for the configured browser's Safe Storage.
    public func testBrowserKeychainAccess() async -> (success: Bool, message: String) {
        let browser = browserCookiesSource
        guard browser != "none" && browser != "custom" else {
            return (true, "No browser keychain required.")
        }

        let keychainService: String
        let keychainAccount: String
        switch browser {
        case "brave":
            keychainService = "Brave Safe Storage"
            keychainAccount = "Brave"
        case "chrome":
            keychainService = "Chrome Safe Storage"
            keychainAccount = "Chrome"
        case "edge":
            keychainService = "Microsoft Edge Safe Storage"
            keychainAccount = "Microsoft Edge"
        case "safari", "firefox":
            return (true, "\(browser.capitalized) does not require Chromium Safe Storage keychain access.")
        default:
            return (true, "Ready.")
        }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let proc = Process()
                proc.executableURL = URL(fileURLWithPath: "/usr/bin/security")
                proc.arguments = ["find-generic-password", "-w", "-a", keychainAccount, "-s", keychainService]
                let pipe = Pipe()
                proc.standardOutput = pipe
                proc.standardError = pipe

                do {
                    try proc.run()
                    proc.waitUntilExit()
                    if proc.terminationStatus == 0 {
                        continuation.resume(returning: (true, "Keychain authorized! Cookies are accessible."))
                    } else {
                        continuation.resume(returning: (false, "Keychain prompt was cancelled or denied. Click 'Always Allow' when prompted."))
                    }
                } catch {
                    continuation.resume(returning: (false, "Failed to test security: \(error.localizedDescription)"))
                }
            }
        }
    }

    /// Toggles the shortcutsEnabled state and displays an informative HUD toast notification.
    public func toggleShortcuts() {
        self.shortcutsEnabled.toggle()
        if self.shortcutsEnabled {
            SutraToastController.shared.showNotice(
                title: "Shortcuts Enabled",
                message: "Press ⌘⇧S or Shift+Select to summon radial menu.",
                systemImage: "command"
            )
        } else {
            SutraToastController.shared.showNotice(
                title: "Shortcuts Paused",
                message: "Press ⌘⇧0 anytime to re-enable shortcuts.",
                systemImage: "command.slash"
            )
        }
    }
}
