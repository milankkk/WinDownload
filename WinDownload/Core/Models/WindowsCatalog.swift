import Foundation

public struct WindowsCatalog {
    public static let shared = WindowsCatalog()

    public let allProducts: [WindowsProduct]

    public init() {
        self.allProducts = [
            // Windows 11 25H2
            WindowsProduct(
                id: "3321",
                name: "Windows 11 25H2 (V2)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3262", "3324"]
            ),
            WindowsProduct(
                id: "3324",
                name: "Windows 11 Arm64 25H2 (V2)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.arm64],
                relatedIDs: ["3321", "3265"]
            ),
            WindowsProduct(
                id: "3262",
                name: "Windows 11 25H2",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3265", "3321", "3113"]
            ),
            WindowsProduct(
                id: "3265",
                name: "Windows 11 Arm64 25H2",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.arm64],
                relatedIDs: ["3262", "3324", "3131"]
            ),
            WindowsProduct(
                id: "3263",
                name: "Windows 11 25H2 Home China",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3262", "3264"]
            ),
            WindowsProduct(
                id: "3264",
                name: "Windows 11 25H2 Pro China",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3262", "3263"]
            ),

            // Windows 11 24H2
            WindowsProduct(
                id: "3113",
                name: "Windows 11 24H2",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64],
                relatedIDs: ["3262", "3131", "2618"]
            ),
            WindowsProduct(
                id: "3131",
                name: "Windows 11 Arm64 24H2",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.arm64],
                relatedIDs: ["3265", "3113"]
            ),
            WindowsProduct(
                id: "3114",
                name: "Windows 11 24H2 Home China",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64],
                relatedIDs: ["3113", "3115"]
            ),
            WindowsProduct(
                id: "3115",
                name: "Windows 11 24H2 Pro China",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64],
                relatedIDs: ["3113", "3114"]
            ),

            // Windows 10
            WindowsProduct(
                id: "2618",
                name: "Windows 10 22H2 v1",
                build: "Build 19045.2965",
                category: .windows10,
                badge: .eol,
                architectures: [.x64, .x86],
                relatedIDs: ["3113", "3262", "52"]
            ),
            WindowsProduct(
                id: "2378",
                name: "Windows 10 22H2 Home China",
                build: "Build 19045.2006",
                category: .windows10,
                badge: .eol,
                architectures: [.x64],
                relatedIDs: ["2618"]
            ),

            // Windows Server
            WindowsProduct(
                id: "server-2025",
                name: "Windows Server 2025",
                build: "Build 26100 (Evaluation)",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025"
            ),
            WindowsProduct(
                id: "server-2022",
                name: "Windows Server 2022",
                build: "Build 20348 (Evaluation)",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022"
            ),
            WindowsProduct(
                id: "server-2019",
                name: "Windows Server 2019",
                build: "Build 17763 (Evaluation)",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2019"
            ),
            WindowsProduct(
                id: "server-2016",
                name: "Windows Server 2016",
                build: "Build 14393 (Evaluation)",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016"
            ),
            WindowsProduct(
                id: "win11-ent",
                name: "Windows 11 Enterprise",
                build: "Evaluation ISO",
                category: .windowsServer,
                badge: .eval,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise"
            ),

            // Legacy
            WindowsProduct(
                id: "52",
                name: "Windows 8.1",
                build: "Build 9600.17415",
                category: .legacy,
                badge: .legacy,
                architectures: [.x64, .x86],
                relatedIDs: ["2618"]
            )
        ]
    }

    public func products(for category: WindowsCategory) -> [WindowsProduct] {
        allProducts.filter { $0.category == category }
    }

    public func findProduct(id: String) -> WindowsProduct? {
        allProducts.first { $0.id == id }
    }

    public func search(query: String) -> [WindowsProduct] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return allProducts
        }
        let terms = trimmed.split(separator: " ")
        return allProducts.filter { product in
            let text = "\(product.name) \(product.build) \(product.category.rawValue)".lowercased()
            return terms.allSatisfy { text.contains($0) }
        }
    }
}
