import Foundation
import CryptoKit

public struct ChecksumCalculator {
    /// Computes the SHA-256 hash of a file incrementally in chunks.
    public static func computeSHA256(
        for fileURL: URL,
        progress: ((_ bytesProcessed: Int64, _ totalBytes: Int64) -> Void)? = nil
    ) async throws -> String {
        return try await Task.detached(priority: .userInitiated) {
            let handle = try FileHandle(forReadingFrom: fileURL)
            defer { try? handle.close() }

            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let totalBytes = (attributes[.size] as? Int64) ?? 0

            var hasher = SHA256()
            let bufferSize = 1024 * 1024 // 1 MB buffer
            var bytesProcessed: Int64 = 0

            while true {
                try Task.checkCancellation()
                let data = handle.readData(ofLength: bufferSize)
                if data.isEmpty {
                    break
                }
                hasher.update(data: data)
                bytesProcessed += Int64(data.count)
                progress?(bytesProcessed, totalBytes)
            }

            let digest = hasher.finalize()
            return digest.map { String(format: "%02x", $0) }.joined()
        }.value
    }
}
