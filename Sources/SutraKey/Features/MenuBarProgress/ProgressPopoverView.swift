import SwiftUI

/// Popover content showing active download and conversion jobs with live metrics.
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
        let jobs = controller.activeTasks
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.24))
                        .frame(width: 8, height: 8)
                    Text("SutraKey Tasks")
                        .font(.system(size: 13, weight: .bold))
                }

                Spacer()

                Text("\(jobs.count) active")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 2)

            Divider()

            if jobs.isEmpty {
                VStack(spacing: 6) {
                    Text("No Active Tasks")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(jobs) { job in
                            jobRow(for: job)
                        }
                    }
                }
                .frame(maxHeight: 280)
            }
        }
        .padding(14)
        .frame(width: 320)
    }

    @ViewBuilder
    private func jobRow(for job: ConversionJob) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Format badge
                Text(job.action.shortBadge)
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(job.action.accentColor.opacity(0.18))
                    .foregroundColor(job.action.accentColor)
                    .cornerRadius(4)

                // Title / Host
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

                // Cancel button
                Button {
                    onCancelJob(job.id)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }

            // Progress bar
            ProgressView(value: job.progress, total: 1.0)
                .progressViewStyle(.linear)
                .tint(job.action.accentColor)

            // Metrics row: Speed + ETA + Percentage
            HStack {
                Text(job.percentageString)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))

                Spacer()

                if job.status == .postProcessing {
                    Text("Finalizing...")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(job.speed) • ETA: \(job.eta)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.6))
        .cornerRadius(8)
    }
}
