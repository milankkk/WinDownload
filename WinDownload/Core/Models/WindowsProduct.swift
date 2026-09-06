import Foundation

public enum WindowsCategory: String, CaseIterable, Identifiable, Codable {
    case windows11 = "Windows 11"
    case windows10 = "Windows 10"
    case windowsServer = "Windows Server"
    case legacy = "Legacy"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .windows11: return "sparkles"
        case .windows10: return "desktopcomputer"
        case .windowsServer: return "server.rack"
        case .legacy: return "archivebox"
        }
    }
}

public enum WindowsBadge: String, Codable {
    case latest = "LATEST"
    case stable = "STABLE"
    case arm64 = "ARM64"
    case server = "SERVER"
    case eol = "EOL"
    case legacy = "LEGACY"
    case eval = "EVALUATION"
}

public struct WindowsProduct: Identifiable, Hashable, Codable {
    public let id: String
    public let name: String
    public let build: String
    public let category: WindowsCategory
    public let badge: WindowsBadge
    public let architectures: [WindowsArchitecture]
    public let isEvaluation: Bool
    public let evalURL: String?
    public let relatedIDs: [String]

    public init(
        id: String,
        name: String,
        build: String,
        category: WindowsCategory,
        badge: WindowsBadge,
        architectures: [WindowsArchitecture],
        isEvaluation: Bool = false,
        evalURL: String? = nil,
        relatedIDs: [String] = []
    ) {
        self.id = id
        self.name = name
        self.build = build
        self.category = category
        self.badge = badge
        self.architectures = architectures
        self.isEvaluation = isEvaluation
        self.evalURL = evalURL
        self.relatedIDs = relatedIDs
    }

    public var displayName: String {
        name
    }
}

public struct ResolvedDownloadOption: Identifiable, Hashable, Codable {
    public var id: String { uri }
    public let uri: String
    public let architecture: WindowsArchitecture
    public let fileName: String
    public let expiresAt: Date?
    public let isCached: Bool

    public init(
        uri: String,
        architecture: WindowsArchitecture,
        fileName: String? = nil,
        expiresAt: Date? = nil,
        isCached: Bool = false
    ) {
        self.uri = uri
        self.architecture = architecture
        if let fileName = fileName {
            self.fileName = fileName
        } else {
            let bare = uri.components(separatedBy: "?").first ?? uri
            self.fileName = (bare as NSString).lastPathComponent
        }
        self.expiresAt = expiresAt
        self.isCached = isCached
    }
}
