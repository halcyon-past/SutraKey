import Foundation

/// Structured progress output parsed from yt-dlp stdout / stderr streams.
public struct ParsedProgress: Sendable, Equatable {
    public var progress: Double
    public var speed: String
    public var eta: String
    public var stage: String
    public var isPostProcessing: Bool
    public var destinationPath: String?

    public init(
        progress: Double = 0.0,
        speed: String = "--",
        eta: String = "--",
        stage: String = "Connecting...",
        isPostProcessing: Bool = false,
        destinationPath: String? = nil
    ) {
        self.progress = progress
        self.speed = speed
        self.eta = eta
        self.stage = stage
        self.isPostProcessing = isPostProcessing
        self.destinationPath = destinationPath
    }
}

/// Robust regex-based parser for yt-dlp CLI output.
public enum YTDLPProgressParser: Sendable {
    // Matches: [download]  45.2% of  120.50MiB at    8.40MiB/s ETA 00:07 (or Unknown speed/ETA)
    private static let progressRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"\[download\]\s+([0-9]+(?:\.[0-9]+)?)%\s+of[^\n]+at\s+([0-9]+(?:\.[0-9]+)?|Unknown)\s*([A-Za-z/]+)?\s+ETA\s+([0-9:]+|Unknown)"#,
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

    // Merger destination regex: [Merger] Merging formats into "/path/file.mp4"
    private static let mergerRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"Merging formats into\s*["']?([^"']+)["']?"#,
            options: []
        )
    }()

    /// Parses a single line of yt-dlp stdout.
    /// - Parameter line: Raw string emitted from yt-dlp process
    /// - Returns: `ParsedProgress?` if progress or post-processing status was recognized.
    public static func parseLine(_ line: String) -> ParsedProgress? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // 1. Check for post-processing lines first:
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
            if dest == nil, let mergeRegex = mergerRegex {
                let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
                if let match = mergeRegex.firstMatch(in: trimmed, options: [], range: range),
                   let pathRange = Range(match.range(at: 1), in: trimmed) {
                    dest = String(trimmed[pathRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            let stageName: String
            if trimmed.contains("[Merger]") {
                stageName = "Merging H.264 + AAC into MP4..."
            } else if trimmed.contains("[ExtractAudio]") {
                stageName = "Extracting high-bitrate MP3..."
            } else if trimmed.contains("[EmbedThumbnail]") {
                stageName = "Embedding album cover art..."
            } else {
                stageName = "Finalizing media container..."
            }
            return ParsedProgress(
                progress: 0.99,
                speed: "--",
                eta: "Finalizing...",
                stage: stageName,
                isPostProcessing: true,
                destinationPath: dest
            )
        }

        // 2. Full progress pattern with percent, speed, and ETA
        if let regex = progressRegex {
            let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            if let match = regex.firstMatch(in: trimmed, options: [], range: nsRange) {
                guard let pRange = Range(match.range(at: 1), in: trimmed),
                      let speedValRange = Range(match.range(at: 2), in: trimmed),
                      let etaRange = Range(match.range(at: 4), in: trimmed) else {
                    return nil
                }

                let speedUnitRange = match.range(at: 3).location != NSNotFound ? Range(match.range(at: 3), in: trimmed) : nil

                let percentVal = Double(trimmed[pRange]) ?? 0.0
                let speedNum = String(trimmed[speedValRange])
                let speedUnit = speedUnitRange != nil ? String(trimmed[speedUnitRange!]) : ""
                let speed = (speedNum == "Unknown" || speedNum.isEmpty) ? "--" : "\(speedNum) \(speedUnit)".trimmingCharacters(in: .whitespaces)
                let eta = trimmed[etaRange] == "Unknown" ? "--" : String(trimmed[etaRange])

                // Calculate progress as 0.0 to 1.0 rounded to 3 decimal places
                let normalizedProgress = (percentVal / 100.0 * 1000.0).rounded() / 1000.0

                return ParsedProgress(
                    progress: normalizedProgress,
                    speed: speed,
                    eta: eta,
                    stage: "Downloading: \(Int(percentVal))%",
                    isPostProcessing: false,
                    destinationPath: nil
                )
            }
        }

        // 3. Fallback: Just percentage line
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
                    stage: "Downloading: \(Int(percentVal))%",
                    isPostProcessing: percentVal >= 100.0,
                    destinationPath: nil
                )
            }
        }

        // 4. Initial connecting & extracting stages (prevents staying stuck at 0% with no feedback)
        let connectingIndicators = ["Extracting URL:", "Downloading webpage", "Downloading API JSON", "Downloading player", "Downloading m3u8", "Downloading 1 format"]
        if connectingIndicators.contains(where: { trimmed.contains($0) }) {
            return ParsedProgress(
                progress: 0.05,
                speed: "--",
                eta: "Resolving...",
                stage: "Connecting to media stream...",
                isPostProcessing: false,
                destinationPath: nil
            )
        }

        // 5. Destination announced before download chunks begin
        if trimmed.hasPrefix("[download] Destination:") {
            var destPath: String?
            if let destRegex = destinationRegex {
                let range = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
                if let match = destRegex.firstMatch(in: trimmed, options: [], range: range),
                   let pathRange = Range(match.range(at: 1), in: trimmed) {
                    destPath = String(trimmed[pathRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            return ParsedProgress(
                progress: 0.08,
                speed: "--",
                eta: "Starting...",
                stage: "Starting download stream...",
                isPostProcessing: false,
                destinationPath: destPath
            )
        }

        return nil
    }
}
