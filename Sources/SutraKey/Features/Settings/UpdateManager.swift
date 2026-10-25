import AppKit
import Foundation
import os
import SwiftUI

/// Structured release payload fetched from GitHub Releases API.
public struct GitHubReleaseInfo: Codable, Sendable, Equatable {
    public let tagName: String
    public let name: String?
    public let body: String?
    public let htmlUrl: String
    public let publishedAt: String?
    public let assets: [GitHubReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case body
        case htmlUrl = "html_url"
        case publishedAt = "published_at"
        case assets
    }
}

public struct GitHubReleaseAsset: Codable, Sendable, Equatable {
    public let name: String
    public let browserDownloadUrl: String

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadUrl = "browser_download_url"
    }
}

/// Lifecycle states for the in-app update engine.
public enum UpdateStatus: Equatable, Sendable {
    case idle
    case checking
    case upToDate(version: String)
    case updateAvailable(version: String, release: GitHubReleaseInfo, assetURL: URL, isZip: Bool)
    case downloading(progress: Double)
    case installing
    case failed(message: String)
}

/// Download delegate tracking byte progress for real-time UI updates.
private final class DownloadProgressDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    private let onProgress: @Sendable (Double) -> Void
    private let continuation: CheckedContinuation<URL, Error>
    private var hasResumed = false
    private let lock = NSLock()

    init(
        onProgress: @escaping @Sendable (Double) -> Void,
        continuation: CheckedContinuation<URL, Error>
    ) {
        self.onProgress = onProgress
        self.continuation = continuation
        super.init()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = max(0.0, min(1.0, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)))
            onProgress(progress)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        lock.lock()
        defer { lock.unlock() }
        guard !hasResumed else { return }
        hasResumed = true

        do {
            let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let tempDestination = tempDir.appendingPathComponent("sutrakey_download_\(UUID().uuidString).tmp")
            try FileManager.default.moveItem(at: location, to: tempDestination)
            continuation.resume(returning: tempDestination)
        } catch {
            continuation.resume(throwing: error)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            lock.lock()
            defer { lock.unlock() }
            guard !hasResumed else { return }
            hasResumed = true
            continuation.resume(throwing: error)
        }
    }
}

/// Zero-dependency in-place auto-updater for SutraKey.
/// Queries GitHub Releases API, downloads release assets with live progress,
/// verifies bundles, and executes an atomic in-place binary swap with automated relaunch.
@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()

    @Published public private(set) var status: UpdateStatus = .idle
    @Published public private(set) var latestRelease: GitHubReleaseInfo?

    public let currentVersion: String = {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !version.isEmpty {
            return version
        }
        return AppConstants.version
    }()

    public let repoReleasesAPI = URL(string: "https://api.github.com/repos/halcyon-past/SutraKey/releases/latest")!
    public let repoReleasesWeb = URL(string: "https://github.com/halcyon-past/SutraKey/releases")!

    public init() {}

    /// Checks GitHub for the latest release asynchronously.
    public func checkForUpdates() async {
        status = .checking

        do {
            var request = URLRequest(url: repoReleasesAPI)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
            request.setValue("SutraKey-macOS/\(currentVersion)", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 10.0

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                status = .failed(message: "Invalid server response.")
                return
            }

            if httpResponse.statusCode == 404 {
                // No releases published yet on repository
                status = .upToDate(version: currentVersion)
                PreferencesManager.shared.lastUpdateCheckDate = Date()
                return
            }

            guard httpResponse.statusCode == 200 else {
                status = .failed(message: "GitHub API error (status \(httpResponse.statusCode)).")
                return
            }

            let release = try JSONDecoder().decode(GitHubReleaseInfo.self, from: data)
            self.latestRelease = release
            PreferencesManager.shared.lastUpdateCheckDate = Date()

            let remoteVersion = release.tagName.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n\r"))

            if isVersion(remoteVersion, greaterThan: currentVersion) {
                var zipURL: URL?
                var dmgURL: URL?
                for asset in release.assets {
                    guard let url = URL(string: asset.browserDownloadUrl) else { continue }
                    let name = asset.name.lowercased()
                    if name.hasSuffix(".zip") && zipURL == nil {
                        zipURL = url
                    } else if name.hasSuffix(".dmg") && dmgURL == nil {
                        dmgURL = url
                    }
                }

                let preferredURL = zipURL ?? dmgURL ?? URL(string: release.htmlUrl) ?? repoReleasesWeb
                let isZip = zipURL != nil

                status = .updateAvailable(
                    version: remoteVersion,
                    release: release,
                    assetURL: preferredURL,
                    isZip: isZip
                )
                Logger.app.info("Update available: v\(remoteVersion) (Installed: v\(self.currentVersion))")
            } else {
                status = .upToDate(version: currentVersion)
                Logger.app.info("SutraKey is up to date (v\(self.currentVersion)).")
            }
        } catch {
            status = .failed(message: error.localizedDescription)
            Logger.app.error("Update check failed: \(error.localizedDescription)")
        }
    }

    /// Downloads the available update, verifies the bundle, swaps it in-place, and relaunches the app.
    public func downloadAndInstallUpdate() async throws {
        guard case .updateAvailable(_, _, let assetURL, let isZip) = status else {
            throw NSError(
                domain: "UpdateError",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No update is currently available."]
            )
        }

        // Web URL fallback: if binary asset is missing, open release webpage
        if !isZip && !assetURL.path.lowercased().hasSuffix(".dmg") && !assetURL.path.lowercased().hasSuffix(".zip") {
            NSWorkspace.shared.open(assetURL)
            status = .idle
            return
        }

        status = .downloading(progress: 0.0)

        // 1. Download asset with live progress tracking
        let tempDownloadedURL: URL = try await withCheckedThrowingContinuation { continuation in
            let delegate = DownloadProgressDelegate(
                onProgress: { [weak self] progress in
                    Task { @MainActor in
                        self?.status = .downloading(progress: progress)
                    }
                },
                continuation: continuation
            )
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
            let task = session.downloadTask(with: assetURL)
            task.resume()
        }

        defer {
            try? FileManager.default.removeItem(at: tempDownloadedURL)
        }

        status = .installing

        // 2. Prepare staging directory in /tmp
        let stagingUUID = UUID().uuidString
        let stagingDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("SutraKeyUpdate_\(stagingUUID)", isDirectory: true)
        try FileManager.default.createDirectory(at: stagingDir, withIntermediateDirectories: true)

        let extractedAppURL: URL
        if isZip {
            // Extract ZIP package using native ditto
            let zipPath = stagingDir.appendingPathComponent("update.zip")
            try FileManager.default.moveItem(at: tempDownloadedURL, to: zipPath)

            let dittoProcess = Process()
            dittoProcess.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
            dittoProcess.arguments = ["-xk", zipPath.path, stagingDir.path]
            try dittoProcess.run()
            dittoProcess.waitUntilExit()

            guard dittoProcess.terminationStatus == 0 else {
                throw NSError(
                    domain: "UpdateError",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to extract update package."]
                )
            }

            extractedAppURL = stagingDir.appendingPathComponent("SutraKey.app")
        } else {
            // Mount DMG silently and copy SutraKey.app
            let mountPoint = stagingDir.appendingPathComponent("mount", isDirectory: true)
            try FileManager.default.createDirectory(at: mountPoint, withIntermediateDirectories: true)

            let hdiProcess = Process()
            hdiProcess.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
            hdiProcess.arguments = ["attach", "-nobrowse", "-readonly", tempDownloadedURL.path, "-mountpoint", mountPoint.path]
            try hdiProcess.run()
            hdiProcess.waitUntilExit()

            guard hdiProcess.terminationStatus == 0 else {
                throw NSError(
                    domain: "UpdateError",
                    code: 3,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to mount update disk image."]
                )
            }

            defer {
                let detach = Process()
                detach.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil")
                detach.arguments = ["detach", mountPoint.path, "-force"]
                try? detach.run()
                detach.waitUntilExit()
            }

            let mountedApp = mountPoint.appendingPathComponent("SutraKey.app")
            extractedAppURL = stagingDir.appendingPathComponent("SutraKey.app")
            try FileManager.default.copyItem(at: mountedApp, to: extractedAppURL)
        }

        // 3. Verify extracted .app bundle integrity
        let executableURL = extractedAppURL.appendingPathComponent("Contents/MacOS/SutraKey")
        guard FileManager.default.fileExists(atPath: executableURL.path) else {
            throw NSError(
                domain: "UpdateError",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Downloaded bundle is invalid or missing executable."]
            )
        }

        // 4. Resolve target application location
        var targetAppURL = Bundle.main.bundleURL
        if !targetAppURL.path.hasSuffix(".app") || targetAppURL.path.contains(".build") || targetAppURL.path.contains("DerivedData") {
            targetAppURL = URL(fileURLWithPath: "/Applications/SutraKey.app")
        }

        // 5. Generate detached shell updater script
        let scriptPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("sutrakey_updater_\(stagingUUID).sh")
        let currentPID = ProcessInfo.processInfo.processIdentifier

        let scriptContent = """
        #!/bin/sh
        # Wait for the current SutraKey process to terminate
        while kill -0 \(currentPID) 2>/dev/null; do
            sleep 0.1
        done

        # Atomic swap
        rm -rf "\(targetAppURL.path)"
        cp -R "\(extractedAppURL.path)" "\(targetAppURL.path)"
        xattr -dr com.apple.quarantine "\(targetAppURL.path)" 2>/dev/null || true

        # Cleanup staging
        rm -rf "\(stagingDir.path)"
        rm -f "\(scriptPath.path)"

        # Relaunch newly updated app
        open "\(targetAppURL.path)"
        """

        try scriptContent.write(to: scriptPath, atomically: true, encoding: .utf8)

        var perms = try FileManager.default.attributesOfItem(atPath: scriptPath.path)
        perms[.posixPermissions] = 0o755
        try FileManager.default.setAttributes(perms, ofItemAtPath: scriptPath.path)

        // 6. Launch detached updater process in background
        let swapProcess = Process()
        swapProcess.executableURL = URL(fileURLWithPath: "/bin/sh")
        swapProcess.arguments = [scriptPath.path]
        try swapProcess.run()

        // 7. Terminate running app cleanly so update script can proceed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.terminate(nil)
        }
    }

    /// Opens the latest release webpage or downloads the direct DMG asset manually.
    public func openDownloadOrReleasePage() {
        if let dmgAsset = latestRelease?.assets.first(where: { $0.name.lowercased().hasSuffix(".dmg") }),
           let dmgURL = URL(string: dmgAsset.browserDownloadUrl) {
            NSWorkspace.shared.open(dmgURL)
            return
        }

        if let releaseUrl = latestRelease?.htmlUrl, let url = URL(string: releaseUrl) {
            NSWorkspace.shared.open(url)
            return
        }

        NSWorkspace.shared.open(repoReleasesWeb)
    }

    /// Compares two semver version strings (e.g. "1.1.0" > "1.0.0").
    public func isVersion(_ candidate: String, greaterThan current: String) -> Bool {
        let clean1 = candidate.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n\r"))
        let clean2 = current.trimmingCharacters(in: CharacterSet(charactersIn: "vV \t\n\r"))

        let v1 = clean1.split(separator: ".").compactMap { Int($0) }
        let v2 = clean2.split(separator: ".").compactMap { Int($0) }

        let count = max(v1.count, v2.count)
        for i in 0..<count {
            let part1 = i < v1.count ? v1[i] : 0
            let part2 = i < v2.count ? v2[i] : 0
            if part1 > part2 {
                return true
            } else if part1 < part2 {
                return false
            }
        }
        return false
    }
}
