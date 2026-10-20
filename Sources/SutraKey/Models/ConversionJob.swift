import Foundation

/// Lifecycle states for an active or finished conversion job.
public enum JobStatus: String, Sendable, Equatable {
    case queued
    case downloading
    case postProcessing
    case completed
    case failed
    case cancelled
}

/// Represents an individual conversion/download task tracked by SutraKey.
public struct ConversionJob: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let sourceURL: URL
    public let action: ConversionAction
    public var title: String
    public var domain: String
    public var progress: Double // 0.0 to 1.0
    public var speed: String
    public var eta: String
    public var status: JobStatus
    public var destinationFileURL: URL?
    public var errorMessage: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        sourceURL: URL,
        action: ConversionAction,
        title: String? = nil,
        domain: String? = nil,
        progress: Double = 0.0,
        speed: String = "--",
        eta: String = "--",
        status: JobStatus = .queued,
        destinationFileURL: URL? = nil,
        errorMessage: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.action = action
        self.title = title ?? sourceURL.host ?? "Media"
        self.domain = domain ?? (sourceURL.host ?? "web")
        self.progress = progress
        self.speed = speed
        self.eta = eta
        self.status = status
        self.destinationFileURL = destinationFileURL
        self.errorMessage = errorMessage
        self.createdAt = createdAt
    }

    public var isTerminal: Bool {
        status == .completed || status == .failed || status == .cancelled
    }

    public var percentageString: String {
        let percent = Int(progress * 100)
        return "\(percent)%"
    }
}
