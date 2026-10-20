import AppKit
import SwiftUI

/// Popover content showing active download and conversion jobs with live metrics,
/// recent download history, and direct access to Settings.
public struct ProgressPopoverView: View {
    @ObservedObject public var controller: EphemeralStatusBarController
    public let onCancelJob: (UUID) -> Void

    public init(controller: EphemeralStatusBarController = .shared, onCancelJob: @escaping (UUID) -> Void) {
        self.controller = controller
        self.onCancelJob = onCancelJob
    }

    public init(jobs: [ConversionJob], onCancelJob: @escaping (UUID) -> Void) {
        let mock = EphemeralStatusBarController()
        mock.hideStatusItem()
        for j in jobs {
            mock.taskDidStart(j)
        }
        self.controller = mock
        self.onCancelJob = onCancelJob
    }

    public var body: some View {
        let activeJobs = controller.activeTasks
        let completedJobs = controller.recentCompletedTasks

        VStack(alignment: .leading, spacing: 12) {
            // Header Bar
            HStack(alignment: .center) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.24))
                        .frame(width: 8, height: 8)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.6), radius: 3)

                    Text("SutraKey")
                        .font(.system(size: 13, weight: .bold))

                    if !activeJobs.isEmpty {
                        Text("\(activeJobs.count) active")
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1.5)
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                // Settings Gear Button
                Button {
                    SettingsWindowController.shared.showSettings()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings (⌘,)")
            }
            .padding(.horizontal, 2)

            Divider()

            // Main Content Area
            if activeJobs.isEmpty && completedJobs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("No Active Tasks")
                        .font(.system(size: 12, weight: .medium))
                    Text("Hold Shift and select any link to convert")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        // Active Tasks
                        ForEach(activeJobs) { job in
                            activeJobCard(for: job)
                        }

                        // Recent Completed Tasks
                        if !completedJobs.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Recent Downloads")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.top, 4)

                                ForEach(completedJobs) { job in
                                    completedJobRow(for: job)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
            }

            Divider()

            // Footer Bar
            HStack {
                Button {
                    let dir = PreferencesManager.shared.downloadDirectory
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dir.path)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                        Text(PreferencesManager.shared.downloadDirectory.lastPathComponent)
                            .font(.system(size: 11, weight: .medium))
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Open download destination in Finder")

                Spacer()

                Button {
                    SettingsWindowController.shared.showSettings()
                } label: {
                    Text("Preferences...")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 340)
    }

    // MARK: - Active Job Card

    @ViewBuilder
    private func activeJobCard(for job: ConversionJob) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Row 1: Badge + Title + Cancel Button
            HStack(spacing: 8) {
                Text(job.action.shortBadge)
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(job.action.accentColor.opacity(0.18))
                    .foregroundColor(job.action.accentColor)
                    .cornerRadius(4)

                VStack(alignment: .leading, spacing: 1) {
                    Text(job.title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)

                    Text(job.domain)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    onCancelJob(job.id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary.opacity(0.8))
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .help("Cancel task")
            }

            // Row 2: Animated Progress Bar
            ProgressView(value: max(job.progress, 0.05), total: 1.0)
                .progressViewStyle(.linear)
                .tint(job.action.accentColor)

            // Row 3: Current Stage + Speed + ETA
            HStack(alignment: .center) {
                Text(job.currentStage)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                if job.status == .postProcessing {
                    Text("Finalizing...")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(job.action.accentColor)
                } else if job.progress > 0.05 && job.speed != "--" {
                    Text("\(job.speed) • \(job.eta)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                } else {
                    Text(job.percentageString)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.75))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Completed Job Row

    @ViewBuilder
    private func completedJobRow(for job: ConversionJob) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 12))

            VStack(alignment: .leading, spacing: 1) {
                Text(job.title)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)

                Text(job.action.title)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let dest = job.destinationFileURL {
                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([dest])
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Reveal file in Finder")

                Button {
                    NSWorkspace.shared.open(dest)
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Open downloaded file")
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.45))
        .cornerRadius(8)
    }
}
