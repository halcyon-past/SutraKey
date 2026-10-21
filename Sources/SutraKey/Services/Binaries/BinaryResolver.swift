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

    public struct JSRuntime: Sendable, Equatable {
        public let name: String
        public let executablePath: String

        public init(name: String, executablePath: String) {
            self.name = name
            self.executablePath = executablePath
        }
    }

    /// Resolves available JavaScript runtime (deno, node, bun, quickjs) for yt-dlp EJS challenge solving.
    public static var jsRuntime: JSRuntime? {
        resolveJSRuntime()
    }

    private static func resolveJSRuntime() -> JSRuntime? {
        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser

        // 1. Direct candidate paths
        let directCandidates: [(name: String, path: String)] = [
            ("deno", "/opt/homebrew/bin/deno"),
            ("node", "/opt/homebrew/bin/node"),
            ("bun", "/opt/homebrew/bin/bun"),
            ("quickjs", "/opt/homebrew/bin/quickjs"),
            ("deno", "/usr/local/bin/deno"),
            ("node", "/usr/local/bin/node"),
            ("bun", "/usr/local/bin/bun"),
            ("deno", home.appendingPathComponent(".deno/bin/deno").path),
            ("bun", home.appendingPathComponent(".bun/bin/bun").path),
            ("node", home.appendingPathComponent(".volta/bin/node").path)
        ]

        for candidate in directCandidates {
            if fileManager.isExecutableFile(atPath: candidate.path) {
                return JSRuntime(name: candidate.name, executablePath: candidate.path)
            }
        }

        // 2. Scan NVM versions (~/.nvm/versions/node/v*.*.*/bin/node)
        let nvmDir = home.appendingPathComponent(".nvm/versions/node")
        if let versions = try? fileManager.contentsOfDirectory(atPath: nvmDir.path).sorted().reversed() {
            for v in versions {
                let candidate = nvmDir.appendingPathComponent("\(v)/bin/node").path
                if fileManager.isExecutableFile(atPath: candidate) {
                    return JSRuntime(name: "node", executablePath: candidate)
                }
            }
        }

        // 3. Scan FNM (~/.local/share/fnm/current/bin/node or ~/.fnm/current/bin/node)
        let fnmCandidates = [
            home.appendingPathComponent(".local/share/fnm/current/bin/node").path,
            home.appendingPathComponent(".fnm/current/bin/node").path
        ]
        for fnmPath in fnmCandidates {
            if fileManager.isExecutableFile(atPath: fnmPath) {
                return JSRuntime(name: "node", executablePath: fnmPath)
            }
        }

        // 4. Scan asdf shims (~/.asdf/shims/node)
        let asdfNode = home.appendingPathComponent(".asdf/shims/node").path
        if fileManager.isExecutableFile(atPath: asdfNode) {
            return JSRuntime(name: "node", executablePath: asdfNode)
        }

        // 5. Check system PATH
        if let pathEnv = ProcessInfo.processInfo.environment["PATH"] {
            for segment in pathEnv.split(separator: ":") {
                for name in ["deno", "node", "bun", "quickjs"] {
                    let candidate = URL(fileURLWithPath: String(segment)).appendingPathComponent(name).path
                    if fileManager.isExecutableFile(atPath: candidate) {
                        return JSRuntime(name: name, executablePath: candidate)
                    }
                }
            }
        }

        return nil
    }

    /// Resolves path to custom yt-dlp plugins directory (e.g. for patched Instagram extractors).
    public static var pluginsDirectory: URL? {
        if let resourceURL = Bundle.main.resourceURL {
            let candidate = resourceURL.appendingPathComponent("yt_dlp_plugins")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
        }
        #if SWIFT_PACKAGE
        if let modulePlugin = Bundle.module.url(forResource: "yt_dlp_plugins", withExtension: nil),
           FileManager.default.fileExists(atPath: modulePlugin.path) {
            return modulePlugin
        }
        #endif
        let projectPlugin = URL(fileURLWithPath: "Sources/SutraKey/Resources/yt_dlp_plugins")
        if FileManager.default.fileExists(atPath: projectPlugin.path) {
            return projectPlugin
        }
        return nil
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
