import Foundation
import os

/// Runs yt-dlp in a background subprocess, streaming progress events and handling cancellation.
public final class YTDLPProcessRunner: Sendable {
    private let processLock = OSAllocatedUnfairLock<Process?>(initialState: nil)

    public init() {}

    /// Cancels running process by sending SIGTERM.
    public func cancel() {
        processLock.withLock { proc in
            if let proc = proc, proc.isRunning {
                Logger.conversion.info("Terminating active yt-dlp process PID: \(proc.processIdentifier)")
                proc.terminate()
            }
        }
    }

    /// Executes yt-dlp for a given target URL and conversion action.
    /// - Parameters:
    ///   - url: Target media URL
    ///   - action: Target conversion action
    ///   - onProgress: Closure invoked on stdout progress updates (progress, speed, eta)
    /// - Returns: Destination file URL in ~/Downloads
    public func execute(
        url: URL,
        action: ConversionAction,
        onProgress: @escaping @Sendable (Double, String, String) -> Void
    ) async throws -> URL {
        guard let ytdlpExecutable = BinaryResolver.ytdlpPath else {
            throw NSError(
                domain: "cloud.aritro.sutrakey",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "yt-dlp not found. Install it via 'brew install yt-dlp' or place in ~/.local/share/sutrakey/bin"]
            )
        }

        let downloadsPath = URLSanitizer.downloadsDirectory.path
        let outputTemplate = "\(downloadsPath)/%(title).120B [%(id)s].%(ext)s"

        var arguments: [String] = [
            "--no-exec",
            "--restrict-filenames",
            "--newline",
            "--print", "after_move:filepath",
            "-o", outputTemplate
        ]

        if let ffmpeg = BinaryResolver.ffmpegPath {
            arguments.append(contentsOf: ["--ffmpeg-location", ffmpeg])
        }

        switch action {
        case .video:
            // Prefer native H.264 / AAC so macOS QuickTime Player and iOS can play the video natively with zero corruption.
            arguments.append(contentsOf: [
                "-f", "bv*[vcodec^=avc]+ba[ext=m4a]/bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]/bv*+ba/b",
                "--format-sort", "vcodec:h264,res,acodec:m4a",
                "--merge-output-format", "mp4",
                "--postprocessor-args", "Merger:-c:v libx264 -c:a aac -movflags +faststart"
            ])
        case .audio:
            arguments.append(contentsOf: [
                "-x",
                "--audio-format", "mp3",
                "--audio-quality", "0",
                "--embed-thumbnail",
                "--add-metadata"
            ])
        case .subtitles:
            arguments.append(contentsOf: [
                "--write-subs",
                "--write-auto-subs",
                "--sub-format", "srt",
                "--sub-langs", "all,-live_chat",
                "--convert-subs", "srt",
                "--skip-download"
            ])
        case .gallery:
            arguments.append(contentsOf: [
                "--write-thumbnail",
                "--skip-download"
            ])
        case .pdf:
            throw NSError(
                domain: "cloud.aritro.sutrakey",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "PDF conversion is handled by WebToPDFService"]
            )
        }

        arguments.append(url.absoluteString)

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: ytdlpExecutable)
        proc.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        proc.standardOutput = stdoutPipe
        proc.standardError = stderrPipe

        processLock.withLock { $0 = proc }

        let destinationLock = OSAllocatedUnfairLock<String?>(initialState: nil)
        let bufferLock = OSAllocatedUnfairLock<String>(initialState: "")

        stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty else { return }
            if let textChunk = String(data: data, encoding: .utf8) {
                bufferLock.withLock { buffer in
                    buffer += textChunk
                    while let newlineIndex = buffer.firstIndex(of: "\n") {
                        let line = String(buffer[..<newlineIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                        buffer.removeSubrange(...newlineIndex)
                        guard !line.isEmpty else { continue }

                        // Check if line is the printed final destination path from --print after_move:filepath
                        if line.hasPrefix("/") {
                            destinationLock.withLock { $0 = line }
                        }

                        if let parsed = YTDLPProgressParser.parseLine(line) {
                            onProgress(parsed.progress, parsed.speed, parsed.eta)
                            if let dest = parsed.destinationPath {
                                destinationLock.withLock { $0 = dest }
                            }
                        }
                    }
                }
            }
        }

        try proc.run()
        proc.waitUntilExit()

        stdoutPipe.fileHandleForReading.readabilityHandler = nil
        stderrPipe.fileHandleForReading.readabilityHandler = nil

        let status = proc.terminationStatus
        guard status == 0 else {
            let errorData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMsg = String(data: errorData, encoding: .utf8) ?? "Process exited with code \(status)"
            throw NSError(
                domain: "cloud.aritro.sutrakey",
                code: Int(status),
                userInfo: [NSLocalizedDescriptionKey: errorMsg]
            )
        }

        if let detected = destinationLock.withLock({ $0 }) {
            return URL(fileURLWithPath: detected)
        }

        // Fallback default output directory
        return URLSanitizer.downloadsDirectory
    }
}
