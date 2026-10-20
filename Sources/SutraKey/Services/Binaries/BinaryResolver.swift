import Foundation
import os

/// Resolves paths to local yt-dlp and ffmpeg binaries and handles self-updating.
public enum BinaryResolver: Sendable {
    private static let binarySearchDirectories: [URL] = {
        var dirs: [URL] = []

        // 1. App Bundle Resources/Binaries
        if let resourceURL = Bundle.main.resourceURL {
            dirs.append(resourceURL.appendingPathComponent("Binaries"))
        }

        // 2. User local share ~/.local/share/sutrakey/bin
        let home = FileManager.default.homeDirectoryForCurrentUser
        dirs.append(home.appendingPathComponent(".local/share/sutrakey/bin"))

        // 3. Homebrew Apple Silicon
        dirs.append(URL(fileURLWithPath: "/opt/homebrew/bin"))

        // 4. Homebrew Intel / standard Unix bin
        dirs.append(URL(fileURLWithPath: "/usr/local/bin"))
        dirs.append(URL(fileURLWithPath: "/usr/bin"))

        return dirs
    }()

    /// Resolves executable path for the given binary name (e.g., "yt-dlp", "ffmpeg").
    public static func resolveBinary(named name: String) -> String? {
        let fileManager = FileManager.default

        for dir in binarySearchDirectories {
            let candidate = dir.appendingPathComponent(name).path
            if fileManager.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }

        // Check system PATH
        if let pathEnv = ProcessInfo.processInfo.environment["PATH"] {
            for segment in pathEnv.split(separator: ":") {
                let candidate = URL(fileURLWithPath: String(segment)).appendingPathComponent(name).path
                if fileManager.isExecutableFile(atPath: candidate) {
                    return candidate
                }
            }
        }

        return nil
    }

    /// Resolves path to yt-dlp.
    public static var ytdlpPath: String? {
        resolveBinary(named: "yt-dlp")
    }

    /// Resolves path to ffmpeg.
    public static var ffmpegPath: String? {
        resolveBinary(named: "ffmpeg")
    }

    /// Executes `yt-dlp -U` to update yt-dlp in-place.
    @discardableResult
    public static func updateYTDLP() async throws -> String {
        guard let binaryPath = ytdlpPath else {
            throw NSError(
                domain: "cloud.aritro.sutrakey",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "yt-dlp executable not found on system"]
            )
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: binaryPath)
        process.arguments = ["-U"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        Logger.conversion.info("yt-dlp update completed with exit code \(process.terminationStatus): \(output)")
        return output
    }
}
