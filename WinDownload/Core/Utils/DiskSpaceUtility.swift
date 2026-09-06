import Foundation

public struct DiskSpaceUtility {
    /// Returns the volume available storage in bytes at the specified URL.
    public static func availableBytes(at url: URL) -> Int64? {
        do {
            let values = try url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
            if let important = values.volumeAvailableCapacityForImportantUsage {
                return important
            }
            let standardValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            if let available = standardValues.volumeAvailableCapacity {
                return Int64(available)
            }
        } catch {
            return nil
        }
        return nil
    }

    /// Formats the available disk space as a human-readable gigabyte string.
    public static func formattedAvailableSpace(at url: URL) -> String {
        guard let bytes = availableBytes(at: url) else {
            return "Checking disk space..."
        }
        let gb = Double(bytes) / 1_073_741_824.0
        return String(format: "%.1f GB available", gb)
    }

    /// Checks if the target volume has sufficient free space for an ISO download.
    public static func hasSufficientSpace(at url: URL, requiredBytes: Int64 = 9_000_000_000) -> Bool {
        guard let bytes = availableBytes(at: url) else { return true }
        return bytes >= requiredBytes
    }
}
