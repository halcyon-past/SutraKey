import Foundation
import Testing
@testable import SutraKey

@Suite("DownloadsPathResolutionTests", .serialized)
struct DownloadsPathResolutionTests {

    @Test("Output directory strictly resolves to user ~/Downloads")
    func testOutputDirectoryAlwaysResolvesToUserDownloads() {
        let originalPref = UserDefaults.standard.string(forKey: "cloud.aritro.sutrakey.downloadPath")
        defer {
            if let original = originalPref {
                UserDefaults.standard.set(original, forKey: "cloud.aritro.sutrakey.downloadPath")
            } else {
                UserDefaults.standard.removeObject(forKey: "cloud.aritro.sutrakey.downloadPath")
            }
        }
        UserDefaults.standard.removeObject(forKey: "cloud.aritro.sutrakey.downloadPath")

        let downloads = URLSanitizer.downloadsDirectory

        // Verify it points to the user's Downloads folder
        #expect(downloads.lastPathComponent == "Downloads")
        #expect(downloads.isFileURL == true)

        // Standard clean title
        let safeDest = URLSanitizer.resolveSafeDestinationURL(forTitle: "SutraKey Demo", extension: "mp4")
        #expect(safeDest.deletingLastPathComponent().standardizedFileURL.path == downloads.path)
        #expect(safeDest.pathExtension == "mp4")
        #expect(safeDest.lastPathComponent.contains("SutraKey Demo"))

        // Malicious path traversal attempts in title:
        // e.g. "../../etc/passwd", "../System/Library", "..\\..\\Windows"
        let maliciousTitles = [
            "../../../etc/cron.d/malicious",
            "../secret_file",
            "..\\..\\Desktop\\hacked",
            "/absolute/root/override",
            "video/../../traversal",
            "..."
        ]

        for malicious in maliciousTitles {
            let resolved = URLSanitizer.resolveSafeDestinationURL(forTitle: malicious, extension: "mp3")

            // Strict Assertion 1: Must be inside Downloads directory
            let parentDir = resolved.deletingLastPathComponent().standardizedFileURL
            #expect(parentDir.path == downloads.path, "Security breach: \(resolved.path) escaped Downloads directory!")

            // Strict Assertion 2: Must NOT contain any path traversal components
            #expect(!resolved.path.contains("/../"), "Path contains ../ traversal: \(resolved.path)")
            #expect(!resolved.lastPathComponent.contains("/"), "Filename contains illegal slash: \(resolved.lastPathComponent)")
        }
    }
}
