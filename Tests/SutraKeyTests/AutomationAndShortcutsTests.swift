import Foundation
import Testing
@testable import SutraKey

@Suite("AutomationAndShortcutsTests", .serialized)
struct AutomationAndShortcutsTests {

    @Test("SutraURLRouter parses sutrakey://download with various formats")
    @MainActor
    func testURLRouterDownloadParsing() {
        // Video download route
        let videoURL = URL(string: "sutrakey://download?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ&format=video")!
        let routeVideo = SutraURLRouter.parse(url: videoURL)
        if case .download(let targetURL, let action) = routeVideo {
            #expect(action == .video)
            #expect(targetURL.host == "www.youtube.com")
        } else {
            Issue.record("Expected .download route for video")
        }

        // Audio extraction route
        let audioURL = URL(string: "sutrakey://download?url=https://soundcloud.com/artist/track&format=mp3")!
        let routeAudio = SutraURLRouter.parse(url: audioURL)
        if case .download(let targetURL, let action) = routeAudio {
            #expect(action == .audio)
            #expect(targetURL.host == "soundcloud.com")
        } else {
            Issue.record("Expected .download route for audio")
        }

        // PDF conversion route
        let pdfURL = URL(string: "sutrakey://download?url=https://en.wikipedia.org/wiki/Swift&format=pdf")!
        let routePDF = SutraURLRouter.parse(url: pdfURL)
        if case .download(let targetURL, let action) = routePDF {
            #expect(action == .pdf)
            #expect(targetURL.host == "en.wikipedia.org")
        } else {
            Issue.record("Expected .download route for PDF")
        }
    }

    @Test("SutraURLRouter parses shorthand command paths")
    @MainActor
    func testURLRouterShorthandPaths() {
        // Shorthand video
        let shortVideo = URL(string: "sutrakey://video?url=https://vimeo.com/123456")!
        if case .download(let targetURL, let action) = SutraURLRouter.parse(url: shortVideo) {
            #expect(action == .video)
            #expect(targetURL.host == "vimeo.com")
        } else {
            Issue.record("Expected .download for shorthand video")
        }

        // Shorthand audio
        let shortAudio = URL(string: "sutrakey://audio?url=https://example.com/podcast.mp3")!
        if case .download(let targetURL, let action) = SutraURLRouter.parse(url: shortAudio) {
            #expect(action == .audio)
            #expect(targetURL.host == "example.com")
        } else {
            Issue.record("Expected .download for shorthand audio")
        }

        // Shorthand settings
        let settingsURL = URL(string: "sutrakey://settings")!
        #expect(SutraURLRouter.parse(url: settingsURL) == .settings)

        // Invalid scheme rejection
        let invalidScheme = URL(string: "https://example.com")!
        #expect(SutraURLRouter.parse(url: invalidScheme) == nil)
    }

    @Test("SutraToastController configures interactive notification category and actions")
    @MainActor
    func testNotificationActionsConfiguration() {
        #expect(SutraToastController.completedCategory == "cloud.aritro.sutrakey.task.completed")
        #expect(SutraToastController.actionOpen == "ACTION_OPEN")
        #expect(SutraToastController.actionQuickLook == "ACTION_QUICK_LOOK")
        #expect(SutraToastController.actionCopyFile == "ACTION_COPY_FILE")
        #expect(SutraToastController.actionDelete == "ACTION_DELETE")
    }

    @Test("AppIntents metadata and titles match system action specifications")
    func testAppIntentsMetadata() {
        #expect(DownloadVideoIntent.title == "Download Video from URL")
        #expect(DownloadVideoIntent.openAppWhenRun == false)

        #expect(ExtractAudioIntent.title == "Extract Audio from URL")
        #expect(ExtractAudioIntent.openAppWhenRun == false)

        #expect(ConvertWebpageToPDFIntent.title == "Convert Webpage to Clean PDF")
        #expect(ConvertWebpageToPDFIntent.openAppWhenRun == false)

        #expect(DownloadSubtitlesIntent.title == "Download Subtitles from URL")
        #expect(DownloadSubtitlesIntent.openAppWhenRun == false)

        #expect(OpenSutraKeySettingsIntent.title == "Open SutraKey Settings")
        #expect(OpenSutraKeySettingsIntent.openAppWhenRun == true)
    }
}
