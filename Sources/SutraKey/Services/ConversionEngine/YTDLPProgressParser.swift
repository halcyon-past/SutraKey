import Foundation

/// Structured progress output parsed from yt-dlp stdout / stderr streams.
public struct ParsedProgress: Sendable, Equatable {
    public var progress: Double
    public var speed: String
    public var eta: String
    public var isPostProcessing: Bool
    public var destinationPath: String?

    public init(
        progress: Double = 0.0,
        speed: String = "--",
        eta: String = "--",
        isPostProcessing: Bool = false,
        destinationPath: String? = nil
    ) {
        self.progress = progress
        self.speed = speed
        self.eta = eta
        self.isPostProcessing = isPostProcessing
        self.destinationPath = destinationPath
    }
}

/// Robust regex-based parser for yt-dlp CLI output.
public enum YTDLPProgressParser: Sendable {
    // Matches: [download]  45.2% of  120.50MiB at    8.40MiB/s ETA 00:07
    private static let progressRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"\[download\]\s+([0-9]+(?:\.[0-9]+)?)%\s+of[^\n]+at\s+([0-9]+(?:\.[0-9]+)?)\s*([A-Za-z/]+)\s+ETA\s+([0-9:]+)"#,
            options: []
        )
    }()

    // Fallback simple download percentage regex: [download] 45.2%
    private static let percentageRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"\[download\]\s+([0-9]+(?:\.[0-9]+)?)%"#,
            options: []
        )
    }()

    // Destination file detection regex: [ExtractAudio] Destination: /path/file.mp3 or [download] Destination: ...
    private static let destinationRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"Destination:\s*(.+)$"#,
            options: []
        )
    }()

    /// Parses a single line of yt-dlp stdout.
    /// - Parameter line: Raw string emitted from yt-dlp process
    /// - Returns: `ParsedProgress?` if progress or post-processing status was recognized.
    public static func parseLine(_ line: String) -> ParsedProgress? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Check for post-processing lines first:
        // e.g. [ExtractAudio], [Merger], [FixupM3u8], [ffmpeg], [EmbedThumbnail]
        let postProcessingTags = ["[ExtractAudio]", "[Merger]", "[Fixup", "[ffmpeg]", "[EmbedThumbnail]", "[Metadata]"]
        let isPost = postProcessingTags.contains { trimmed.contains($0) }

        if isPost {
            var dest: String?
            if let destRegex = destinationRegex {
                let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
                if let match = destRegex.firstMatch(in: trimmed, options: [], range: range),
                   let pathRange = Range(match.range(at: 1), in: trimmed) {
                    dest = String(trimmed[pathRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            return ParsedProgress(
                progress: 0.99,
                speed: "--",
                eta: "Finalizing...",
                isPostProcessing: true,
                destinationPath: dest
            )
        }

        // Full progress pattern with percent, speed, and ETA
        if let regex = progressRegex {
            let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            if let match = regex.firstMatch(in: trimmed, options: [], range: nsRange) {
                guard let pRange = Range(match.range(at: 1), in: trimmed),
                      let speedValRange = Range(match.range(at: 2), in: trimmed),
                      let speedUnitRange = Range(match.range(at: 3), in: trimmed),
                      let etaRange = Range(match.range(at: 4), in: trimmed) else {
                    return nil
                }

                let percentVal = Double(trimmed[pRange]) ?? 0.0
                let speedNum = String(trimmed[speedValRange])
                let speedUnit = String(trimmed[speedUnitRange])
                let speed = "\(speedNum) \(speedUnit)"
                let eta = String(trimmed[etaRange])

                // Calculate progress as 0.0 to 1.0 rounded to 3 decimal places
                let normalizedProgress = (percentVal / 100.0 * 1000.0).rounded() / 1000.0

                return ParsedProgress(
                    progress: normalizedProgress,
                    speed: speed,
                    eta: eta,
                    isPostProcessing: false,
                    destinationPath: nil
                )
            }
        }

        // Fallback: Just percentage line
        if let pRegex = percentageRegex {
            let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            if let match = pRegex.firstMatch(in: trimmed, options: [], range: nsRange),
               let pRange = Range(match.range(at: 1), in: trimmed) {
                let percentVal = Double(trimmed[pRange]) ?? 0.0
                let normalizedProgress = (percentVal / 100.0 * 1000.0).rounded() / 1000.0
                return ParsedProgress(
                    progress: normalizedProgress,
                    speed: "--",
                    eta: "--",
                    isPostProcessing: percentVal >= 100.0,
                    destinationPath: nil
                )
            }
        }

        return nil
    }
}
