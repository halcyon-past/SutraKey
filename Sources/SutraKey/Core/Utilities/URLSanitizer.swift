import Foundation

/// Validates, sanitizes, and extracts clean HTTP/HTTPS URLs from raw selected text.
public enum URLSanitizer: Sendable {
    private static let urlDetector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }()

    /// Extracts and sanitizes the first valid HTTP or HTTPS URL found in a text snippet.
    /// - Parameter text: Raw user text selection or clipboard content
    /// - Returns: A validated `URL` or `nil` if no valid web URL is found.
    public static func extractURL(from text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // 1. First attempt: Direct URL initialization with stripped brackets and quotes
        let cleanedDirect = cleanPunctuationAndEnclosures(trimmed)
        if let directURL = URL(string: cleanedDirect), isValidWebURL(directURL) {
            return normalizeWebURL(directURL)
        }

        // 2. Second attempt: Detect embedded URLs using NSDataDetector
        if let detector = urlDetector {
            let nsString = trimmed as NSString
            let matches = detector.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsString.length))
            for match in matches {
                if let candidateURL = match.url, isValidWebURL(candidateURL) {
                    return normalizeWebURL(candidateURL)
                }
            }
        }

        // 3. Third attempt: Regex search for http:// or https:// substrings
        let regexPattern = #"https?:\/\/[^\s<>"'()]+"#
        if let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive) {
            let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            if let match = regex.firstMatch(in: trimmed, options: [], range: range),
               let matchRange = Range(match.range, in: trimmed) {
                let candidateString = cleanPunctuationAndEnclosures(String(trimmed[matchRange]))
                if let url = URL(string: candidateString), isValidWebURL(url) {
                    return normalizeWebURL(url)
                }
            }
        }

        return nil
    }

    /// Convenience alias extracting and sanitizing a URL string.
    public static func sanitize(_ text: String) -> URL? {
        extractURL(from: text)
    }

    /// Normalizes URLs into clean canonical formats (e.g. Instagram /reels/ -> /reel/ and strips tracking parameters).
    public static func normalizeWebURL(_ url: URL) -> URL {
        var str = url.absoluteString

        // 1. Normalize Instagram /reels/ to /reel/
        if str.contains("instagram.com/reels/") {
            str = str.replacingOccurrences(of: "instagram.com/reels/", with: "instagram.com/reel/")
        }

        // 2. Clean tracking queries from Instagram URLs (e.g. ?hl=en, ?igsh=...)
        if let components = URLComponents(string: str), let host = components.host?.lowercased() {
            if host.contains("instagram.com") {
                var comp = components
                comp.query = nil
                if let cleaned = comp.url {
                    return cleaned
                }
            }
        }

        return URL(string: str) ?? url
    }

    /// Strips enclosing quotes, markdown links, parentheses, and trailing punctuation.
    private static func cleanPunctuationAndEnclosures(_ string: String) -> String {
        var str = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip leading/trailing angle brackets, quotes, braces, parentheses
        let leadingChars = CharacterSet(charactersIn: "<>\"'([{")
        let trailingChars = CharacterSet(charactersIn: "<>\"')]}.,;!?")

        str = str.trimmingCharacters(in: leadingChars)
        str = str.trimmingCharacters(in: trailingChars)
        return str
    }

    /// Asserts URL scheme is strictly http or https, and host is present.
    public static func isValidWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return false
        }
        guard let host = url.host, !host.isEmpty, host.contains(".") else {
            return false
        }
        return true
    }

    /// Resolves the user's configured download directory (default: ~/Downloads).
    public static var downloadsDirectory: URL {
        if let custom = UserDefaults.standard.string(forKey: "cloud.aritro.sutrakey.downloadPath"), !custom.isEmpty {
            let candidate = URL(fileURLWithPath: custom, isDirectory: true)
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: candidate.path, isDirectory: &isDir), isDir.boolValue {
                return candidate.standardizedFileURL
            }
        }
        if let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            return downloads.standardizedFileURL
        }
        // Fallback to home/Downloads
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent("Downloads", isDirectory: true).standardizedFileURL
    }

    /// Sanitizes file titles, strictly preventing path traversal (`../`) and illegal filesystem characters.
    /// Ensures that any generated output file URL is strictly within the user's Downloads directory.
    /// - Parameters:
    ///   - rawTitle: Unsanitized video/article title, possibly containing "../" or "/"
    ///   - ext: Desired file extension (e.g., "mp4", "pdf")
    /// - Returns: A secure destination URL strictly inside `~/Downloads`.
    public static func resolveSafeDestinationURL(forTitle rawTitle: String, extension ext: String) -> URL {
        let baseDownloads = downloadsDirectory

        // 1. Remove dangerous traversal elements: ../, ..\, /, \
        var sanitized = rawTitle
            .replacingOccurrences(of: "../", with: "_")
            .replacingOccurrences(of: "..\\", with: "_")
            .replacingOccurrences(of: "..", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: ":", with: " -")
            .replacingOccurrences(of: "\0", with: "")

        // 2. Trim whitespace and limit length to 120 bytes for macOS HFS+/APFS safety
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.isEmpty {
            sanitized = "SutraKey_Media_\(Int(Date().timeIntervalSince1970))"
        }

        if sanitized.utf8.count > 120 {
            let index = sanitized.index(sanitized.startIndex, offsetBy: min(sanitized.count, 60))
            sanitized = String(sanitized[..<index])
        }

        let cleanExt = ext.trimmingCharacters(in: CharacterSet(charactersIn: ". \t\n\r"))
        let filename = "\(sanitized).\(cleanExt)"

        // Append to downloads directory
        let candidateURL = baseDownloads.appendingPathComponent(filename).standardizedFileURL

        // Verification guard: Destination must strictly have baseDownloads as prefix
        let candidatePath = candidateURL.path
        let downloadsPath = baseDownloads.path
        guard candidatePath.hasPrefix(downloadsPath) && !candidatePath.contains("/../") else {
            // Failsafe fallback
            return baseDownloads.appendingPathComponent("SutraKey_SafeOutput_\(UUID().uuidString).\(cleanExt)")
        }

        return candidateURL
    }
}
