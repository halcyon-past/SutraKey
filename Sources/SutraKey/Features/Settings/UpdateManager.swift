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

/// State of the GitHub release updater.
public enum UpdateStatus: Equatable {
    case idle
    case checking
    case updateAvailable(version: String, release: GitHubReleaseInfo)
    case upToDate(version: String)
    case failed(message: String)
}

/// Checks GitHub releases for updates and provides one-click update actions.
@MainActor
public final class UpdateManager: ObservableObject {
    public static let shared = UpdateManager()

    @Published public private(set) var status: UpdateStatus = .idle
    @Published public private(set) var latestRelease: GitHubReleaseInfo?

    public let currentVersion: String = {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, !version.isEmpty {
            return version
        }
        return "1.0.0"
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
                status = .updateAvailable(version: remoteVersion, release: release)
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

    /// Opens the latest release webpage or downloads the direct DMG asset.
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
        let v1 = candidate.split(separator: ".").compactMap { Int($0) }
        let v2 = current.split(separator: ".").compactMap { Int($0) }

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
