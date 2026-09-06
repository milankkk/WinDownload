import Foundation

public struct WindowsCatalog {
    public static let shared = WindowsCatalog()

    public let allProducts: [WindowsProduct]

    public init() {
        self.allProducts = [
            // Windows 11 24H2 (Primary Recommended)
            WindowsProduct(
                id: "3113",
                name: "Windows 11 24H2",
                editionName: "Windows 11 24H2 (Home / Pro)",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3131",
                relatedIDs: ["3131", "3262", "2618"]
            ),
            WindowsProduct(
                id: "3131",
                name: "Windows 11 Arm64 24H2",
                editionName: "Windows 11 Arm64 24H2",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                relatedIDs: ["3113", "3265"]
            ),

            // Windows 11 Enterprise LTSC 2024
            WindowsProduct(
                id: "win11-ent-ltsc-2024",
                name: "Windows 11 Enterprise LTSC 2024",
                editionName: "Enterprise LTSC 2024",
                build: "Build 26100.1742 (LTSC)",
                category: .windows11,
                badge: .ltsc,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/?linkid=2289029",
                relatedIDs: ["3113", "win11-ent"]
            ),

            // Windows 11 25H2
            WindowsProduct(
                id: "3262",
                name: "Windows 11 25H2",
                editionName: "Windows 11 25H2 (Insider / Preview)",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3113", "3321"]
            ),
            WindowsProduct(
                id: "3321",
                name: "Windows 11 25H2 (V2)",
                editionName: "Windows 11 25H2 (V2)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.x64],
                relatedIDs: ["3262", "3324"]
            ),
            WindowsProduct(
                id: "3324",
                name: "Windows 11 Arm64 25H2 (V2)",
                editionName: "Windows 11 Arm64 25H2 (V2)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.arm64],
                relatedIDs: ["3321", "3265"]
            ),

            // Windows 11 Enterprise (Annual)
            WindowsProduct(
                id: "win11-ent",
                name: "Windows 11 Enterprise",
                editionName: "Enterprise (24H2 Evaluation)",
                build: "Build 26100",
                category: .windows11,
                badge: .eval,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISE_S_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/?linkid=2334167"
            ),

            // Windows 11 China
            WindowsProduct(
                id: "3263",
                name: "Windows 11 25H2 Home China",
                editionName: "Windows 11 25H2 Home (China)",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64]
            ),

            // Windows 10 22H2
            WindowsProduct(
                id: "2618",
                name: "Windows 10 22H2",
                editionName: "Windows 10 22H2 (Home / Pro)",
                build: "Build 19045.2965",
                category: .windows10,
                badge: .stable,
                architectures: [.x64, .x86],
                relatedIDs: ["3113", "win10-ent-ltsc-2021"]
            ),

            // Windows 10 Enterprise LTSC 2021
            WindowsProduct(
                id: "win10-ent-ltsc-2021",
                name: "Windows 10 Enterprise LTSC 2021",
                editionName: "Enterprise LTSC 2021",
                build: "Build 19044.1288 (LTSC)",
                category: .windows10,
                badge: .ltsc,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-download.microsoft.com/download/db/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195404",
                relatedIDs: ["2618"]
            ),

            // Windows 10 China
            WindowsProduct(
                id: "2378",
                name: "Windows 10 22H2 Home China",
                editionName: "Windows 10 22H2 Home (China)",
                build: "Build 19045.2006",
                category: .windows10,
                badge: .eol,
                architectures: [.x64]
            ),

            // Windows Server 2025
            WindowsProduct(
                id: "server-2025",
                name: "Windows Server 2025",
                editionName: "Windows Server 2025",
                build: "Build 26100",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?linkid=2289945"
            ),

            // Windows Server 2022
            WindowsProduct(
                id: "server-2022",
                name: "Windows Server 2022",
                editionName: "Windows Server 2022",
                build: "Build 20348",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195280"
            ),

            // Windows Server 2019
            WindowsProduct(
                id: "server-2019",
                name: "Windows Server 2019",
                editionName: "Windows Server 2019",
                build: "Build 17763",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195167"
            ),

            // Windows Server 2016
            WindowsProduct(
                id: "server-2016",
                name: "Windows Server 2016",
                editionName: "Windows Server 2016",
                build: "Build 14393",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016"
            ),

            // Windows 8.1
            WindowsProduct(
                id: "52",
                name: "Windows 8.1",
                editionName: "Windows 8.1 (Pro / Core)",
                build: "Build 9600.17415",
                category: .windows8,
                badge: .legacy,
                architectures: [.x64, .x86],
                relatedIDs: ["2618"]
            )
        ]
    }

    public func products(for category: WindowsCategory) -> [WindowsProduct] {
        allProducts.filter { $0.category == category }
    }

    public func editions(for category: WindowsCategory) -> [WindowsProduct] {
        // Return primary selectable editions for category, filtering out secondary arch variants
        allProducts.filter { product in
            product.category == category &&
            product.id != "3131" && product.id != "3324" && product.id != "3321"
        }
    }

    public func resolveProduct(for product: WindowsProduct, architecture: WindowsArchitecture) -> WindowsProduct {
        if architecture == .arm64, let armID = product.arm64EquivalentID, let armProduct = findProduct(id: armID) {
            return armProduct
        }
        return product
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
            let text = "\(product.name) \(product.editionName) \(product.build) \(product.category.rawValue)".lowercased()
            return terms.allSatisfy { text.contains($0) }
        }
    }
}
