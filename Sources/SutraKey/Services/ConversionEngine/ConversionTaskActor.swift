import AppKit
import Foundation
import os

/// Thread-safe actor coordinating conversion jobs, background subprocesses, and status broadcasts.
public actor ConversionTaskActor {
    public static let shared = ConversionTaskActor()

    private var jobs: [UUID: ConversionJob] = [:]
    private var activeRunners: [UUID: YTDLPProcessRunner] = [:]

    // Callbacks dispatched onto MainActor for UI synchronization
    private var onJobStartedHandler: (@MainActor @Sendable (ConversionJob) -> Void)?
    private var onJobUpdatedHandler: (@MainActor @Sendable (ConversionJob) -> Void)?
    private var onJobCompletedHandler: (@MainActor @Sendable (ConversionJob) -> Void)?
    private var onJobFailedHandler: (@MainActor @Sendable (ConversionJob, String) -> Void)?

    public init() {}

    public func setHandlers(
        onStarted: (@MainActor @Sendable (ConversionJob) -> Void)? = nil,
        onUpdated: (@MainActor @Sendable (ConversionJob) -> Void)? = nil,
        onCompleted: (@MainActor @Sendable (ConversionJob) -> Void)? = nil,
        onFailed: (@MainActor @Sendable (ConversionJob, String) -> Void)? = nil
    ) {
        self.onJobStartedHandler = onStarted
        self.onJobUpdatedHandler = onUpdated
        self.onJobCompletedHandler = onCompleted
        self.onJobFailedHandler = onFailed
    }

    /// Enqueues a new conversion job and initiates execution asynchronously.
    @discardableResult
    public func enqueueJob(url: URL, action: ConversionAction) -> UUID {
        let job = ConversionJob(
            sourceURL: url,
            action: action,
            title: url.host ?? "Media Task",
            domain: url.host ?? "web",
            progress: 0.0,
            status: .queued
        )
        jobs[job.id] = job

        Logger.conversion.info("Enqueued job \(job.id) for \(action.rawValue) from \(url.absoluteString)")

        notifyStarted(job)

        Task {
            await self.executeJob(id: job.id)
        }

        return job.id
    }

    /// Cancels an active job and kills its subprocess via SIGTERM.
    public func cancelJob(id: UUID) {
        if let runner = activeRunners[id] {
            runner.cancel()
            activeRunners.removeValue(forKey: id)
        }
        if var job = jobs[id] {
            job.status = .cancelled
            job.errorMessage = "Cancelled by user"
            jobs[id] = job
            notifyUpdated(job)
        }
    }

    /// Returns list of currently active (non-terminal) jobs.
    public func getActiveJobs() -> [ConversionJob] {
        return jobs.values.filter { !$0.isTerminal }.sorted(by: { $0.createdAt > $1.createdAt })
    }

    /// Returns all tracked jobs.
    public func getAllJobs() -> [ConversionJob] {
        return Array(jobs.values.sorted(by: { $0.createdAt > $1.createdAt }))
    }

    /// Returns job by ID.
    public func getJob(id: UUID) -> ConversionJob? {
        return jobs[id]
    }

    // MARK: - Private Execution

    private func executeJob(id: UUID) async {
        guard var initialJob = jobs[id] else { return }
        initialJob.status = .downloading
        jobs[id] = initialJob

        notifyUpdated(initialJob)

        let targetURL = initialJob.sourceURL
        let targetAction = initialJob.action

        do {
            if targetAction == .pdf {
                self.updateProgress(id: id, progress: 0.15, speed: "", eta: "", stage: "Loading webpage...")
                let pdfService = await WebToPDFService()
                let savedURL = try await pdfService.convertToPDF(
                    url: targetURL,
                    onStageUpdate: { [weak self] stage, prog in
                        guard let self = self else { return }
                        Task {
                            await self.updateProgress(id: id, progress: prog, speed: "", eta: "", stage: stage)
                        }
                    }
                )

                if var completedJob = jobs[id] {
                    completedJob.destinationFileURL = savedURL
                    completedJob.progress = 1.0
                    completedJob.status = .completed
                    completedJob.currentStage = "Finished"
                    jobs[id] = completedJob
                    notifyCompleted(completedJob)
                }
            } else {
                let runner = YTDLPProcessRunner()
                activeRunners[id] = runner

                let cookieArgs = await MainActor.run {
                    PreferencesManager.shared.resolveCookieArguments(for: targetURL)
                }

                let destinationURL = try await runner.execute(
                    url: targetURL,
                    action: targetAction,
                    cookieArguments: cookieArgs,
                    onProgress: { [weak self] progress, speed, eta, stage in
                        guard let self = self else { return }
                        Task {
                            await self.updateProgress(id: id, progress: progress, speed: speed, eta: eta, stage: stage)
                        }
                    }
                )

                activeRunners.removeValue(forKey: id)
                if var completedJob = jobs[id] {
                    completedJob.destinationFileURL = destinationURL
                    completedJob.progress = 1.0
                    completedJob.currentStage = "Saved to Downloads"
                    completedJob.status = .completed
                    jobs[id] = completedJob
                    notifyCompleted(completedJob)
                }
            }
        } catch {
            activeRunners.removeValue(forKey: id)
            if var failedJob = jobs[id] {
                failedJob.status = .failed
                failedJob.errorMessage = error.localizedDescription
                failedJob.currentStage = "Failed: \(error.localizedDescription)"
                jobs[id] = failedJob
                Logger.conversion.error("Job \(id) failed: \(error.localizedDescription)")
                notifyFailed(failedJob, error: error.localizedDescription)
            }
        }
    }

    private func notifyStarted(_ job: ConversionJob) {
        let handler = self.onJobStartedHandler
        Task { @MainActor in
            handler?(job)
        }
    }

    private func notifyUpdated(_ job: ConversionJob) {
        let handler = self.onJobUpdatedHandler
        Task { @MainActor in
            handler?(job)
        }
    }

    private func notifyCompleted(_ job: ConversionJob) {
        let handler = self.onJobCompletedHandler
        Task { @MainActor in
            handler?(job)
        }
    }

    private func notifyFailed(_ job: ConversionJob, error: String) {
        let handler = self.onJobFailedHandler
        Task { @MainActor in
            handler?(job, error)
        }
    }

    private func updateProgress(id: UUID, progress: Double, speed: String, eta: String, stage: String) {
        guard var job = jobs[id], !job.isTerminal else { return }
        job.progress = progress
        job.speed = speed
        job.eta = eta
        job.currentStage = stage
        if progress >= 0.99 {
            job.status = .postProcessing
        } else {
            job.status = .downloading
        }
        jobs[id] = job
        notifyUpdated(job)
    }
}
