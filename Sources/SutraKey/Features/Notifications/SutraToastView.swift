import AppKit
import SwiftUI

/// Toast notification content types.
public enum ToastType {
    case start(job: ConversionJob)
    case success(job: ConversionJob, fileURL: URL)
    case failure(job: ConversionJob, message: String)
    case notice(title: String, message: String, systemImage: String, actionTitle: String?, action: (@MainActor () -> Void)?)
}

/// Frosted glass floating HUD toast view with actionable buttons.
public struct SutraToastView: View {
    public let type: ToastType
    public let onDismiss: () -> Void

    public init(type: ToastType, onDismiss: @escaping () -> Void) {
        self.type = type
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            iconView

            // Text Info
            VStack(alignment: .leading, spacing: 3) {
                Text(titleText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                Text(subtitleText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)

                // Action button if applicable
                actionButtonView
                    .padding(.top, 4)
            }

            Spacer(minLength: 4)

            // Close button
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 340)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.35), radius: 18, x: 0, y: 8)
    }

    @ViewBuilder
    private var iconView: some View {
        switch type {
        case .start(let job):
            ZStack {
                Circle()
                    .fill(job.action.accentColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: job.action.sfSymbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(job.action.accentColor)
            }
        case .success:
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
            }
        case .failure:
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.red)
            }
        case .notice(_, _, let systemImage, _, _):
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.24))
            }
        }
    }

    private var titleText: String {
        switch type {
        case .start:
            return "SutraKey Started"
        case .success:
            return "Saved to Downloads"
        case .failure:
            return "Conversion Failed"
        case .notice(let title, _, _, _, _):
            return title
        }
    }

    private var subtitleText: String {
        switch type {
        case .start(let job):
            return "Converting to \(job.action.title) • \(job.domain)"
        case .success(_, let fileURL):
            return fileURL.lastPathComponent
        case .failure(let job, let message):
            return "\(job.action.shortBadge): \(message)"
        case .notice(_, let message, _, _, _):
            return message
        }
    }

    @ViewBuilder
    private var actionButtonView: some View {
        switch type {
        case .start:
            EmptyView()
        case .success(_, let fileURL):
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
                onDismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                    Text("Show in Finder")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.2))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        case .failure(_, let message):
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(message, forType: .string)
                onDismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy Error Log")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.red.opacity(0.3))
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        case .notice(_, _, _, let actionTitle, let action):
            if let title = actionTitle, let act = action {
                Button {
                    act()
                    onDismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text(title)
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 1.0, green: 0.42, blue: 0.24).opacity(0.4))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
