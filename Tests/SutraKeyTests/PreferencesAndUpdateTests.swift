import Foundation
import Testing
@testable import SutraKey

@Suite("PreferencesAndUpdateTests", .serialized)
struct PreferencesAndUpdateTests {

    @Test("UpdateManager semver comparison evaluates newer versions correctly")
    @MainActor
    func testSemverComparison() {
        let updater = UpdateManager()

        #expect(updater.isVersion("1.1.0", greaterThan: "1.0.0") == true)
        #expect(updater.isVersion("2.0.0", greaterThan: "1.9.9") == true)
        #expect(updater.isVersion("1.0.1", greaterThan: "1.0.0") == true)
        #expect(updater.isVersion("1.0.2", greaterThan: "1.0.1") == true)
        #expect(updater.isVersion("1.0.3", greaterThan: "1.0.2") == true)
        #expect(updater.isVersion("1.0.4", greaterThan: "1.0.3") == true)
        #expect(updater.isVersion("1.0.0", greaterThan: "1.0.0") == false)
        #expect(updater.isVersion("0.9.9", greaterThan: "1.0.0") == false)
        #expect(updater.isVersion("1.0.0", greaterThan: "1.0.1") == false)
    }

    @Test("PreferencesManager custom download path updates URLSanitizer destination")
    @MainActor
    func testCustomDownloadDirectory() {
        let prefs = PreferencesManager.shared
        let originalDir = prefs.downloadDirectory
        defer {
            prefs.downloadDirectory = originalDir
        }

        let tempDir = FileManager.default.temporaryDirectory.standardizedFileURL
        prefs.downloadDirectory = tempDir

        #expect(URLSanitizer.downloadsDirectory.path == tempDir.path)

        // Restore
        prefs.downloadDirectory = originalDir
        #expect(URLSanitizer.downloadsDirectory.path == originalDir.path)
    }

    @Test("PreferencesManager shortcutsEnabled toggle flips and persists state")
    @MainActor
    func testShortcutsEnabledToggle() {
        let prefs = PreferencesManager.shared
        let original = prefs.shortcutsEnabled
        defer { prefs.shortcutsEnabled = original }

        prefs.shortcutsEnabled = true
        #expect(prefs.shortcutsEnabled == true)

        prefs.toggleShortcuts(showToast: false)
        #expect(prefs.shortcutsEnabled == false)

        prefs.toggleShortcuts(showToast: false)
        #expect(prefs.shortcutsEnabled == true)
    }

    @Test("YTDLPProgressParser identifies extraction stages to prevent sticking at 0%")
    func testExtractionStageRecognition() {
        let extractLine = "[youtube] Extracting URL: https://www.youtube.com/watch?v=2u19wN1tDT4"
        let parsed = YTDLPProgressParser.parseLine(extractLine)

        #expect(parsed != nil)
        #expect(parsed?.progress ?? 0 > 0.0)
        #expect(parsed?.stage.contains("Connecting") == true)

        let mergerLine = "[Merger] Merging formats into \"output.mp4\""
        let parsedMerger = YTDLPProgressParser.parseLine(mergerLine)

        #expect(parsedMerger != nil)
        #expect(parsedMerger?.isPostProcessing == true)
        #expect(parsedMerger?.stage.contains("Merging") == true)
    }

    @Test("PreferencesManager scopes browser cookies strictly to login-walled domains")
    @MainActor
    func testCookieScopingByDomain() {
        let prefs = PreferencesManager.shared
        let originalSource = prefs.browserCookiesSource
        let originalScoping = prefs.cookiesOnlyForAuthRequiredSites
        defer {
            prefs.browserCookiesSource = originalSource
            prefs.cookiesOnlyForAuthRequiredSites = originalScoping
        }

        prefs.browserCookiesSource = "brave"
        prefs.cookiesOnlyForAuthRequiredSites = true

        // YouTube should receive ZERO cookie arguments to avoid Keychain prompts and bot blocks
        let youtubeURL = URL(string: "https://www.youtube.com/watch?v=wYbDxLp0dao")!
        #expect(prefs.resolveCookieArguments(for: youtubeURL).isEmpty)

        let redditURL = URL(string: "https://www.reddit.com/r/funny/comments/abc123/funny_video/")!
        #expect(prefs.resolveCookieArguments(for: redditURL).isEmpty)

        // Instagram MUST receive browser cookie arguments
        let instaURL = URL(string: "https://www.instagram.com/p/Dc_U1XRpWEI/")!
        let instaArgs = prefs.resolveCookieArguments(for: instaURL)
        #expect(instaArgs == ["--cookies-from-browser", "brave"])

        // When scoping is disabled, all domains receive cookies
        prefs.cookiesOnlyForAuthRequiredSites = false
        #expect(prefs.resolveCookieArguments(for: youtubeURL) == ["--cookies-from-browser", "brave"])
    }

    @Test("BinaryResolver discovers local JavaScript runtime when available")
    func testJSRuntimeResolution() {
        // If a JS runtime (node, deno, bun, quickjs) is present on system, jsRuntime resolves correctly
        let runtime = BinaryResolver.jsRuntime
        if let runtime = runtime {
            #expect(!runtime.name.isEmpty)
            #expect(FileManager.default.isExecutableFile(atPath: runtime.executablePath))
        }
    }
}
