import AppKit
import SwiftUI

/// Settings view providing configuration for downloads, quality, menu bar presence, and GitHub auto-updates.
public struct SettingsView: View {
    @ObservedObject public var prefs: PreferencesManager
    @ObservedObject public var updater: UpdateManager

    @State private var selectedTab: SettingsTab = .general

    public enum SettingsTab: String, CaseIterable, Identifiable {
        case general = "General"
        case quality = "Quality"
        case updates = "Updates"
        case about = "About"

        public var id: String { rawValue }

        public var icon: String {
            switch self {
            case .general: return "gearshape.fill"
            case .quality: return "slider.horizontal.3"
            case .updates: return "arrow.triangle.2.circlepath.circle.fill"
            case .about: return "info.circle.fill"
            }
        }
    }

    public init(
        prefs: PreferencesManager = .shared,
        updater: UpdateManager = .shared
    ) {
        self.prefs = prefs
        self.updater = updater
    }

    public var body: some View {
        TabView(selection: $selectedTab) {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(SettingsTab.general)

            qualityTab
                .tabItem {
                    Label("Quality", systemImage: "slider.horizontal.3")
                }
                .tag(SettingsTab.quality)

            updatesTab
                .tabItem {
                    Label("Updates", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(SettingsTab.updates)

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(SettingsTab.about)
        }
        .padding(20)
        .frame(width: 520, height: 380)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Download Location")
                        .font(.system(size: 13, weight: .semibold))

                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 16))

                        Text(prefs.downloadDirectory.path)
                            .font(.system(size: 11, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button("Change...") {
                            prefs.selectDownloadDirectory()
                        }

                        Button {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: prefs.downloadDirectory.path)
                        } label: {
                            Image(systemName: "arrow.right.circle")
                        }
                        .help("Reveal in Finder")
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
                    .cornerRadius(8)

                    HStack {
                        Spacer()
                        Button("Reset to ~/Downloads") {
                            prefs.resetDownloadDirectory()
                        }
                        .font(.system(size: 11))
                        .buttonStyle(.link)
                    }
                }
            }

            Divider()
                .padding(.vertical, 4)

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Menu Bar Appearance")
                        .font(.system(size: 13, weight: .semibold))

                    Toggle("Keep menu bar icon always visible", isOn: $prefs.keepStatusBarVisible)
                        .font(.system(size: 12))

                    Text("When disabled, the menu bar icon appears strictly during active downloads and automatically hides when idle.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notifications & Feedback")
                        .font(.system(size: 13, weight: .semibold))

                    Toggle("Play completion chime when media finishes", isOn: $prefs.playCompletionSound)
                        .font(.system(size: 12))

                    Toggle("Show frosted toast HUD banner on complete", isOn: $prefs.showCompletionToast)
                        .font(.system(size: 12))
                }
            }

            Divider()
                .padding(.vertical, 4)

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Authentication & Browser Cookies")
                        .font(.system(size: 13, weight: .semibold))

                    Text("Instagram Stories and age-restricted media require an active authenticated session.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Picker("Import Cookies from:", selection: $prefs.browserCookiesSource) {
                        Text("Brave Browser").tag("brave")
                        Text("Google Chrome").tag("chrome")
                        Text("Safari").tag("safari")
                        Text("Microsoft Edge").tag("edge")
                        Text("Firefox").tag("firefox")
                        Text("Custom cookies.txt File").tag("custom")
                        Text("None (Public Media Only)").tag("none")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 260)

                    if prefs.browserCookiesSource == "custom" {
                        HStack {
                            Text(prefs.customCookiesPath.isEmpty ? "No cookies.txt selected" : prefs.customCookiesPath)
                                .font(.system(size: 11, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .foregroundColor(.secondary)

                            Spacer()

                            Button("Select cookies.txt...") {
                                let panel = NSOpenPanel()
                                panel.canChooseFiles = true
                                panel.canChooseDirectories = false
                                panel.allowsMultipleSelection = false
                                if panel.runModal() == .OK, let url = panel.url {
                                    prefs.customCookiesPath = url.path
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Quality & Formats Tab

    private var qualityTab: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Video Pipeline (MP4)")
                        .font(.system(size: 13, weight: .semibold))

                    Picker("Codec & Container:", selection: $prefs.preferredVideoCodec) {
                        Text("QuickTime Native H.264 + AAC (Recommended)").tag("h264_aac")
                        Text("Maximum Resolution (Highest Available Bitrate)").tag("best")
                    }
                    .pickerStyle(.radioGroup)
                    .font(.system(size: 12))

                    Text("QuickTime Native merges H.264 video with AAC stereo audio to guarantee zero playback or audio sync errors in QuickTime, iOS, and Final Cut Pro.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Audio Pipeline (MP3)")
                        .font(.system(size: 13, weight: .semibold))

                    Picker("Bitrate:", selection: $prefs.preferredAudioBitrate) {
                        Text("320 kbps (Maximum Fidelity CBR)").tag("320k")
                        Text("256 kbps (High Quality)").tag("256k")
                        Text("192 kbps (Standard)").tag("192k")
                    }
                    .pickerStyle(.menu)
                    .frame(width: 280)

                    Text("Extracts audio with embedded high-resolution album artwork and ID3 metadata.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Updates Tab (GitHub Releases Auto-Updater)

    private var updatesTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.24))

                VStack(alignment: .leading, spacing: 2) {
                    Text("SutraKey Updates")
                        .font(.system(size: 15, weight: .bold))
                    Text("Installed Version: v\(updater.currentVersion)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    Task {
                        await updater.checkForUpdates()
                    }
                } label: {
                    if updater.status == .checking {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Check Now")
                    }
                }
                .disabled(updater.status == .checking)
            }
            .padding(.bottom, 4)

            Divider()

            // Dynamic Update Status Banner
            switch updater.status {
            case .idle:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Automatic Update Checks Enabled")
                        .font(.system(size: 12, weight: .medium))
                    if let lastDate = prefs.lastUpdateCheckDate {
                        Text("Last checked: \(lastDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)

            case .checking:
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Checking github.com/halcyon-past/SutraKey for releases...")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)

            case .upToDate(let version):
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("SutraKey v\(version) is the latest version available.")
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)

            case .updateAvailable(let version, let release):
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.orange)
                        Text("New Version Available: v\(version)")
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Button("Download Update") {
                            updater.openDownloadOrReleasePage()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 1.0, green: 0.42, blue: 0.24))
                    }

                    if let notes = release.body, !notes.isEmpty {
                        ScrollView {
                            Text(notes)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 80)
                        .padding(6)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                    }
                }
                .padding(12)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(10)

            case .failed(let message):
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Could not check for updates: \(message)")
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()

            Toggle("Automatically check for updates on launch", isOn: $prefs.autoCheckUpdates)
                .font(.system(size: 12))
        }
        .onAppear {
            if updater.status == .idle && prefs.autoCheckUpdates {
                Task {
                    await updater.checkForUpdates()
                }
            }
        }
    }

    // MARK: - About Tab

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(14)
                .shadow(radius: 4)

            Text("SutraKey (सूत्र)")
                .font(.system(size: 16, weight: .bold))

            Text("Version \(updater.currentVersion) • Universal macOS Binary")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            Text("The invisible thread connecting text selection to instant media & clean documents. 100% Native Swift 6. Zero Telemetry.")
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 360)

            HStack(spacing: 12) {
                Button("GitHub Repository") {
                    if let url = URL(string: "https://github.com/halcyon-past/SutraKey") {
                        NSWorkspace.shared.open(url)
                    }
                }

                Button("Report Issue") {
                    if let url = URL(string: "https://github.com/halcyon-past/SutraKey/issues") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
            .padding(.top, 4)

            Spacer()

            Text("Licensed under MIT License • Open Source")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
