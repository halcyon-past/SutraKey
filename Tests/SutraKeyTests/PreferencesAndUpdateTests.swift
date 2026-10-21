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
}
