import AppIntents
import Foundation

/// App Intent allowing macOS Shortcuts and Siri to download videos from any URL.
public struct DownloadVideoIntent: AppIntent {
    public static let title: LocalizedStringResource = "Download Video from URL"
    public static let description = IntentDescription("Downloads video (up to 4K MP4) from any supported media site using SutraKey.")
    public static let openAppWhenRun: Bool = false

    @Parameter(title: "Media URL", description: "The web URL of the video to download.")
    public var url: URL

    public init() {}

    public init(url: URL) {
        self.url = url
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let sanitized = URLSanitizer.sanitize(url.absoluteString) else {
            throw NSError(
                domain: "SutraKeyIntentError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid media URL provided."]
            )
        }

        let jobId = await ConversionTaskActor.shared.enqueueJob(url: sanitized, action: .video)
        return .result(value: "Enqueued video download (Job ID: \(jobId.uuidString))")
    }
}

/// App Intent allowing macOS Shortcuts and Siri to extract audio from any URL.
public struct ExtractAudioIntent: AppIntent {
    public static let title: LocalizedStringResource = "Extract Audio from URL"
    public static let description = IntentDescription("Extracts 320kbps MP3 audio from any video or media URL using SutraKey.")
    public static let openAppWhenRun: Bool = false

    @Parameter(title: "Media URL", description: "The web URL of the media from which to extract audio.")
    public var url: URL

    public init() {}

    public init(url: URL) {
        self.url = url
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let sanitized = URLSanitizer.sanitize(url.absoluteString) else {
            throw NSError(
                domain: "SutraKeyIntentError",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid media URL provided."]
            )
        }

        let jobId = await ConversionTaskActor.shared.enqueueJob(url: sanitized, action: .audio)
        return .result(value: "Enqueued audio extraction (Job ID: \(jobId.uuidString))")
    }
}

/// App Intent allowing macOS Shortcuts and Siri to convert any webpage to a clean vector PDF.
public struct ConvertWebpageToPDFIntent: AppIntent {
    public static let title: LocalizedStringResource = "Convert Webpage to Clean PDF"
    public static let description = IntentDescription("Captures and renders any webpage into a clean vector A4 PDF using SutraKey's offscreen WebKit engine.")
    public static let openAppWhenRun: Bool = false

    @Parameter(title: "Webpage URL", description: "The web URL of the page to convert to PDF.")
    public var url: URL

    public init() {}

    public init(url: URL) {
        self.url = url
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let sanitized = URLSanitizer.sanitize(url.absoluteString) else {
            throw NSError(
                domain: "SutraKeyIntentError",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "Invalid webpage URL provided."]
            )
        }

        let jobId = await ConversionTaskActor.shared.enqueueJob(url: sanitized, action: .pdf)
        return .result(value: "Enqueued PDF conversion (Job ID: \(jobId.uuidString))")
    }
}

/// App Intent allowing macOS Shortcuts to extract subtitles from a video URL.
public struct DownloadSubtitlesIntent: AppIntent {
    public static let title: LocalizedStringResource = "Download Subtitles from URL"
    public static let description = IntentDescription("Extracts subtitle tracks (SRT/VTT) from any video URL using SutraKey.")
    public static let openAppWhenRun: Bool = false

    @Parameter(title: "Video URL", description: "The web URL of the video to extract subtitles from.")
    public var url: URL

    public init() {}

    public init(url: URL) {
        self.url = url
    }

    @MainActor
    public func perform() async throws -> some IntentResult & ReturnsValue<String> {
        guard let sanitized = URLSanitizer.sanitize(url.absoluteString) else {
            throw NSError(
                domain: "SutraKeyIntentError",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Invalid video URL provided."]
            )
        }

        let jobId = await ConversionTaskActor.shared.enqueueJob(url: sanitized, action: .subtitles)
        return .result(value: "Enqueued subtitles download (Job ID: \(jobId.uuidString))")
    }
}

/// App Intent to open SutraKey Settings.
public struct OpenSutraKeySettingsIntent: AppIntent {
    public static let title: LocalizedStringResource = "Open SutraKey Settings"
    public static let description = IntentDescription("Opens the SutraKey preferences window.")
    public static let openAppWhenRun: Bool = true

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult {
        SettingsWindowController.shared.showSettings()
        return .result()
    }
}

/// Automatically surfaces SutraKey actions in the macOS Shortcuts library and Spotlight search.
public struct SutraShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DownloadVideoIntent(),
            phrases: [
                "Download video with \(.applicationName)",
                "Rip video with \(.applicationName)"
            ],
            shortTitle: "Download Video",
            systemImageName: "film"
        )
        AppShortcut(
            intent: ExtractAudioIntent(),
            phrases: [
                "Extract audio with \(.applicationName)",
                "Save MP3 with \(.applicationName)"
            ],
            shortTitle: "Extract Audio",
            systemImageName: "music.note"
        )
        AppShortcut(
            intent: ConvertWebpageToPDFIntent(),
            phrases: [
                "Convert webpage to PDF with \(.applicationName)",
                "Save page as PDF with \(.applicationName)"
            ],
            shortTitle: "Webpage to PDF",
            systemImageName: "doc.text.viewfinder"
        )
    }
}
