import Foundation
import Combine

@MainActor
public final class WindowsDownloadEngine: ObservableObject {
    @Published public private(set) var status: DownloadStatus = .idle
    @Published public private(set) var progress: DownloadProgressMetrics = DownloadProgressMetrics()
    @Published public private(set) var currentStage: DownloadWorkflowStage = .resolvingLink
    @Published public private(set) var activeFileName: String = ""

    private var activeSession: URLSession?
    private var activeTask: URLSessionDownloadTask?
    private var resumeData: Data?
    private var downloadTaskExecution: Task<Void, Never>?

    public init() {}

    public func startDownload(
        from uri: String,
        destinationDirectory: URL,
        customFileName: String? = nil,
        verifyChecksum: Bool = true
    ) {
        cancel()

        guard let sourceURL = URL(string: uri) else {
            status = .failed(message: "Invalid download link")
            return
        }

        let fileName: String
        if let customFileName = customFileName, !customFileName.isEmpty {
            fileName = customFileName
        } else {
            let bare = uri.components(separatedBy: "?").first ?? uri
            fileName = (bare as NSString).lastPathComponent
        }

        self.activeFileName = fileName
        let destinationURL = destinationDirectory.appendingPathComponent(fileName)

        currentStage = .downloading
        status = .downloading(isPaused: false)
        progress = DownloadProgressMetrics()

        downloadTaskExecution = Task { [weak self] in
            guard let self = self else { return }

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 60
            config.timeoutIntervalForResource = 86_400 // 24 hours max

            let delegate = FileDownloadDelegate(
                expectedBytesFallback: 5_500_000_000, // standard ~5.5 GB fallback
                destinationURL: destinationURL
            ) { [weak self] received, expected, speed, eta in
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    self.progress.bytesDownloaded = received
                    self.progress.totalExpectedBytes = expected
                    self.progress.fractionCompleted = min(1.0, Double(received) / Double(max(expected, 1)))
                    self.progress.speedMBps = speed
                    self.progress.timeRemainingSeconds = eta
                }
            }

            let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
            self.activeSession = session

            let task: URLSessionDownloadTask
            if let resumeData = self.resumeData {
                task = session.downloadTask(withResumeData: resumeData)
                self.resumeData = nil
            } else {
                var request = URLRequest(url: sourceURL)
                request.setValue(
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36",
                    forHTTPHeaderField: "User-Agent"
                )
                task = session.downloadTask(with: request)
            }
            self.activeTask = task

            do {
                let finalURL = try await delegate.awaitCompletion(task: task)

                // Verifying Stage
                if verifyChecksum {
                    self.currentStage = .verifying
                    self.status = .verifying
                    let sha256 = try? await ChecksumCalculator.computeSHA256(for: finalURL)
                    let attributes = try? FileManager.default.attributesOfItem(atPath: finalURL.path)
                    let size = (attributes?[.size] as? Int64) ?? self.progress.bytesDownloaded

                    self.currentStage = .completed
                    self.status = .completed(fileURL: finalURL, fileSize: size, sha256: sha256)
                } else {
                    let attributes = try? FileManager.default.attributesOfItem(atPath: finalURL.path)
                    let size = (attributes?[.size] as? Int64) ?? self.progress.bytesDownloaded
                    self.currentStage = .completed
                    self.status = .completed(fileURL: finalURL, fileSize: size, sha256: nil)
                }
            } catch is CancellationError {
                self.status = .cancelled
            } catch {
                if let urlErr = error as? URLError, urlErr.code == .cancelled {
                    // Handled as pause or cancel
                } else {
                    self.status = .failed(message: error.localizedDescription)
                }
            }

            self.activeTask = nil
            self.activeSession = nil
        }
    }

    public func pause() {
        guard case .downloading(isPaused: false) = status, let task = activeTask else { return }
        task.cancel(byProducingResumeData: { [weak self] data in
            Task { @MainActor [weak self] in
                self?.resumeData = data
                self?.status = .downloading(isPaused: true)
                self?.progress.speedMBps = 0.0
                self?.progress.timeRemainingSeconds = nil
            }
        })
    }

    public func resume(destinationDirectory: URL, originalURI: String) {
        guard case .downloading(isPaused: true) = status else { return }
        startDownload(
            from: originalURI,
            destinationDirectory: destinationDirectory,
            customFileName: activeFileName
        )
    }

    public func cancel() {
        downloadTaskExecution?.cancel()
        downloadTaskExecution = nil
        activeTask?.cancel()
        activeTask = nil
        activeSession?.invalidateAndCancel()
        activeSession = nil
        resumeData = nil
        status = .cancelled
        progress = DownloadProgressMetrics()
    }

    public func reset() {
        cancel()
        status = .idle
        currentStage = .resolvingLink
        activeFileName = ""
    }
}
