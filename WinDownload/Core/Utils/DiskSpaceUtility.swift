import Foundation

public struct DiskSpaceUtility {
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

    public static func formattedAvailableSpace(at url: URL) -> String {
        guard let bytes = availableBytes(at: url) else {
            return "Checking disk space..."
        }
        let gb = Double(bytes) / 1_073_741_824.0
        return String(format: "%.1f GB available", gb)
    }

    public static func hasSufficientSpace(at url: URL, requiredBytes: Int64 = 9_000_000_000) -> Bool {
        guard let bytes = availableBytes(at: url) else { return true }
        return bytes >= requiredBytes
    }
}
