import Foundation

public enum WindowsArchitecture: String, CaseIterable, Identifiable, Codable {
    case x64 = "x64"
    case arm64 = "ARM64"
    case x86 = "x86"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .x64: return "64-bit (x64)"
        case .arm64: return "ARM64"
        case .x86: return "32-bit (x86)"
        }
    }

    /// Returns the user-facing architecture label, including ISA details when expert mode is active.
    public func displayName(expertMode: Bool) -> String {
        if expertMode {
            switch self {
            case .x64: return "64-bit (x64) [AMD64]"
            case .arm64: return "ARM64 [AArch64]"
            case .x86: return "32-bit (x86) [IA-32]"
            }
        }
        return displayName
    }

    public var shortName: String {
        rawValue
    }

    /// Infers the CPU architecture from a file name or description string.
    public static func from(string: String) -> WindowsArchitecture {
        let lower = string.lowercased()
        if lower.contains("arm64") || lower.contains("aarch64") {
            return .arm64
        } else if lower.contains("x64") || lower.contains("64") || lower.contains("amd64") {
            return .x64
        } else if lower.contains("x86") || lower.contains("32") || lower.contains("i386") {
            return .x86
        }
        return .x64
    }

    public static var currentHostRecommended: WindowsArchitecture {
        #if arch(arm64)
        return .arm64
        #else
        return .x64
        #endif
    }
}
