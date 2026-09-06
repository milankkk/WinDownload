import Foundation

public enum DownloadWorkflowStage: String, CaseIterable, Identifiable {
    case resolvingLink = "Resolving Download Link"
    case downloading = "Downloading ISO Image"
    case verifying = "Verifying File & Checksum"
    case completed = "Download Ready"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .resolvingLink: return "network"
        case .downloading: return "arrow.down.circle"
        case .verifying: return "checkmark.shield"
        case .completed: return "checkmark.circle.fill"
        }
    }

    public var orderIndex: Int {
        switch self {
        case .resolvingLink: return 0
        case .downloading: return 1
        case .verifying: return 2
        case .completed: return 3
        }
    }
}

public enum DownloadStatus: Equatable {
    case idle
    case resolving
    case downloading(isPaused: Bool)
    case verifying
    case completed(fileURL: URL, fileSize: Int64, sha256: String?)
    case failed(message: String)
    case cancelled
}

public struct DownloadProgressMetrics: Equatable {
    public var bytesDownloaded: Int64 = 0
    public var totalExpectedBytes: Int64 = 0
    public var fractionCompleted: Double = 0.0
    public var speedMBps: Double = 0.0
    public var timeRemainingSeconds: TimeInterval? = nil

    public init(
        bytesDownloaded: Int64 = 0,
        totalExpectedBytes: Int64 = 0,
        fractionCompleted: Double = 0.0,
        speedMBps: Double = 0.0,
        timeRemainingSeconds: TimeInterval? = nil
    ) {
        self.bytesDownloaded = bytesDownloaded
        self.totalExpectedBytes = totalExpectedBytes
        self.fractionCompleted = fractionCompleted
        self.speedMBps = speedMBps
        self.timeRemainingSeconds = timeRemainingSeconds
    }

    public var formattedSpeed: String {
        if speedMBps <= 0.05 {
            return "-- MB/s"
        }
        return String(format: "%.1f MB/s", speedMBps)
    }

    public var formattedTransferred: String {
        let downloadedGB = Double(bytesDownloaded) / 1_073_741_824.0
        let totalGB = Double(totalExpectedBytes) / 1_073_741_824.0
        if totalExpectedBytes > 0 {
            return String(format: "%.2f GB / %.2f GB", downloadedGB, totalGB)
        } else {
            return String(format: "%.2f GB", downloadedGB)
        }
    }

    public var formattedTimeRemaining: String {
        guard let seconds = timeRemainingSeconds, seconds > 0, !seconds.isInfinite, !seconds.isNaN else {
            return "Calculating..."
        }
        let sec = Int(seconds)
        if sec < 60 {
            return "\(sec)s remaining"
        } else if sec < 3600 {
            let m = sec / 60
            let s = sec % 60
            return "\(m)m \(s)s remaining"
        } else {
            let h = sec / 3600
            let m = (sec % 3600) / 60
            return "\(h)h \(m)m remaining"
        }
    }
}
