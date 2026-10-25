import AppKit
import Foundation
import os

/// Supported routes parsed from the `sutrakey://` deep link URL scheme.
public enum SutraURLRoute: Equatable, Sendable {
    case download(url: URL, action: ConversionAction)
    case settings
    case unknown(String)
}

/// Parses and routes incoming `sutrakey://` deep links.
/// Supports integration with Raycast, Alfred, browser bookmarklets, Terminal, and Shortcuts.app.
@MainActor
public final class SutraURLRouter: NSObject {
    public static let shared = SutraURLRouter()
    public static let supportedScheme = "sutrakey"

    public var onRouteDispatched: ((SutraURLRoute) -> Void)?

    private override init() {
        super.init()
    }

    /// Parses an incoming URL into a strongly-typed `SutraURLRoute`.
    /// Supported formats:
    /// - `sutrakey://download?url=https://...&format=video|audio|pdf|subtitles|gallery`
    /// - `sutrakey://video?url=https://...`
    /// - `sutrakey://audio?url=https://...`
    /// - `sutrakey://pdf?url=https://...`
    /// - `sutrakey://subtitles?url=https://...`
    /// - `sutrakey://gallery?url=https://...`
    /// - `sutrakey://settings` or `sutrakey://preferences`
    public static func parse(url: URL) -> SutraURLRoute? {
        guard let scheme = url.scheme?.lowercased(), scheme == supportedScheme else {
            return nil
        }

        let host = url.host?.lowercased() ?? ""
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
        let command = !host.isEmpty ? host : path

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        // Extract raw URL string from query parameter `url` or `link` or `target`
        let rawTargetURLStr = queryItems.first(where: {
            $0.name.lowercased() == "url" || $0.name.lowercased() == "link" || $0.name.lowercased() == "target"
        })?.value?.trimmingCharacters(in: .whitespacesAndNewlines)

        switch command {
        case "download":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter.")
            }

            let formatParam = queryItems.first(where: {
                $0.name.lowercased() == "format" || $0.name.lowercased() == "type" || $0.name.lowercased() == "mode"
            })?.value?.lowercased() ?? "video"

            let action = mapFormatToAction(formatParam)
            return .download(url: targetURL, action: action)

        case "video", "mp4":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter for video download.")
            }
            return .download(url: targetURL, action: .video)

        case "audio", "mp3", "m4a":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter for audio download.")
            }
            return .download(url: targetURL, action: .audio)

        case "pdf", "document", "webpage":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter for PDF conversion.")
            }
            return .download(url: targetURL, action: .pdf)

        case "subtitles", "subs", "srt":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter for subtitles.")
            }
            return .download(url: targetURL, action: .subtitles)

        case "gallery", "images", "img":
            guard let rawTarget = rawTargetURLStr, let targetURL = URLSanitizer.sanitize(rawTarget) else {
                return .unknown("Missing or invalid 'url' query parameter for gallery.")
            }
            return .download(url: targetURL, action: .gallery)

        case "settings", "preferences":
            return .settings

        default:
            return .unknown(url.absoluteString)
        }
    }

    /// Maps a format string parameter to the corresponding `ConversionAction`.
    public static func mapFormatToAction(_ format: String) -> ConversionAction {
        switch format.lowercased() {
        case "audio", "mp3", "m4a", "wav", "aac":
            return .audio
        case "pdf", "doc", "document", "web", "webpage":
            return .pdf
        case "subtitles", "subs", "srt", "vtt":
            return .subtitles
        case "gallery", "images", "img":
            return .gallery
        default:
            return .video
        }
    }

    /// Evaluates and handles an incoming URL scheme request.
    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let route = Self.parse(url: url) else {
            Logger.app.warning("Received unsupported URL scheme request: \(url.absoluteString)")
            return false
        }

        onRouteDispatched?(route)

        switch route {
        case .download(let targetURL, let action):
            Logger.app.info("Dispatching URL scheme download: \(action.rawValue) -> \(targetURL.absoluteString)")
            Task {
                await ConversionTaskActor.shared.enqueueJob(url: targetURL, action: action)
            }
            SutraToastController.shared.showNotice(
                title: "Download Initiated",
                message: "\(action.title) • \(targetURL.host ?? "link")",
                systemImage: action.sfSymbol
            )
            return true

        case .settings:
            Logger.app.info("Opening Settings via URL scheme.")
            SettingsWindowController.shared.showSettings()
            return true

        case .unknown(let reason):
            Logger.app.error("Unknown URL route: \(reason)")
            SutraToastController.shared.showNotice(
                title: "Invalid SutraKey Link",
                message: reason,
                systemImage: "exclamationmark.triangle.fill"
            )
            return false
        }
    }
}
