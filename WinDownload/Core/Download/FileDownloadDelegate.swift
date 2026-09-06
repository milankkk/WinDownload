import Foundation

public final class FileDownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let expectedBytesFallback: Int64
    private let destinationURL: URL
    private let progressHandler: (_ receivedBytes: Int64, _ expectedBytes: Int64, _ speedMBps: Double, _ eta: TimeInterval?) -> Void
    private var continuation: CheckedContinuation<URL, Error>?

    private var startedAt: Date = Date()
    private var lastSampleDate: Date = Date()
    private var lastSampleBytes: Int64 = 0
    private var speedSamples: [Double] = []

    public init(
        expectedBytesFallback: Int64,
        destinationURL: URL,
        progressHandler: @escaping (_ receivedBytes: Int64, _ expectedBytes: Int64, _ speedMBps: Double, _ eta: TimeInterval?) -> Void
    ) {
        self.expectedBytesFallback = expectedBytesFallback
        self.destinationURL = destinationURL
        self.progressHandler = progressHandler
    }

    public func awaitCompletion(task: URLSessionDownloadTask) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.startedAt = Date()
            self.lastSampleDate = Date()
            self.lastSampleBytes = 0
            task.resume()
        }
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        let expected = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : expectedBytesFallback
        let now = Date()
        let elapsed = now.timeIntervalSince(lastSampleDate)

        var currentSpeedMBps: Double = 0.0
        var eta: TimeInterval? = nil

        if elapsed >= 1.0 {
            let delta = max(0, totalBytesWritten - lastSampleBytes)
            let instantSpeed = (Double(delta) / 1_000_000.0) / elapsed
            speedSamples.append(instantSpeed)
            if speedSamples.count > 5 {
                speedSamples.removeFirst()
            }
            let avgSpeed = speedSamples.reduce(0.0, +) / Double(speedSamples.count)
            currentSpeedMBps = avgSpeed

            let remainingBytes = max(0, expected - totalBytesWritten)
            if avgSpeed > 0.01 {
                eta = Double(remainingBytes) / (avgSpeed * 1_000_000.0)
            }

            lastSampleDate = now
            lastSampleBytes = totalBytesWritten
        } else if !speedSamples.isEmpty {
            currentSpeedMBps = speedSamples.reduce(0.0, +) / Double(speedSamples.count)
        }

        progressHandler(totalBytesWritten, expected, currentSpeedMBps, eta)
    }

    public func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            let fm = FileManager.default
            let parentDir = destinationURL.deletingLastPathComponent()
            if !fm.fileExists(atPath: parentDir.path) {
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }

            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            }

            try fm.moveItem(at: location, to: destinationURL)
            continuation?.resume(returning: destinationURL)
            continuation = nil
        } catch {
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            continuation?.resume(throwing: error)
            continuation = nil
        }
    }
}
