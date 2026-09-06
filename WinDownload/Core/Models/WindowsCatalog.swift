import Foundation

public struct WindowsCatalog {
    public static let shared = WindowsCatalog()

    public let allProducts: [WindowsProduct]

    public init() {
        self.allProducts = [
            // --- Windows 11 ---
            WindowsProduct(
                id: "3113",
                name: "Windows 11 Home / Pro (24H2)",
                editionName: "Home / Pro (24H2)",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3131",
                relatedIDs: ["3131", "3114", "3115", "3262", "2618"]
            ),
            WindowsProduct(
                id: "3114",
                name: "Windows 11 Home China (24H2)",
                editionName: "Home China (24H2)",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3132",
                relatedIDs: ["3132", "3113", "3115"]
            ),
            WindowsProduct(
                id: "3115",
                name: "Windows 11 Pro China (24H2)",
                editionName: "Pro China (24H2)",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .stable,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3133",
                relatedIDs: ["3133", "3113", "3114"]
            ),
            WindowsProduct(
                id: "win11-ent-ltsc-2024",
                name: "Windows 11 Enterprise LTSC (2024)",
                editionName: "Enterprise LTSC (2024)",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .ltsc,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/?linkid=2289029",
                relatedIDs: ["3113", "win11-ent"]
            ),
            WindowsProduct(
                id: "win11-ent",
                name: "Windows 11 Enterprise (24H2)",
                editionName: "Enterprise (24H2)",
                build: "Build 26100",
                category: .windows11,
                badge: .eval,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISE_S_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/?linkid=2334167"
            ),
            WindowsProduct(
                id: "3262",
                name: "Windows 11 Insider Preview (25H2)",
                editionName: "Insider Preview (25H2)",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3265",
                relatedIDs: ["3265", "3321", "3113"]
            ),
            WindowsProduct(
                id: "3263",
                name: "Windows 11 Home China (25H2)",
                editionName: "Home China (25H2)",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3266",
                relatedIDs: ["3266", "3264", "3262"]
            ),
            WindowsProduct(
                id: "3264",
                name: "Windows 11 Pro China (25H2)",
                editionName: "Pro China (25H2)",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3267",
                relatedIDs: ["3267", "3263", "3262"]
            ),
            WindowsProduct(
                id: "3321",
                name: "Windows 11 Insider Preview (25H2 Refresh)",
                editionName: "Insider Preview (25H2 Refresh)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3324",
                relatedIDs: ["3324", "3262"]
            ),
            WindowsProduct(
                id: "3322",
                name: "Windows 11 Home China (25H2 Refresh)",
                editionName: "Home China (25H2 Refresh)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3325",
                relatedIDs: ["3325", "3323", "3321"]
            ),
            WindowsProduct(
                id: "3323",
                name: "Windows 11 Pro China (25H2 Refresh)",
                editionName: "Pro China (25H2 Refresh)",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .latest,
                architectures: [.x64, .arm64],
                arm64EquivalentID: "3326",
                relatedIDs: ["3326", "3322", "3321"]
            ),

            // Secondary ARM64 variants resolved automatically when ARM64 architecture is chosen
            WindowsProduct(
                id: "3131",
                name: "Windows 11 Home / Pro (24H2) ARM64",
                editionName: "Home / Pro (24H2) ARM64",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3113", "3265"]
            ),
            WindowsProduct(
                id: "3132",
                name: "Windows 11 Home China (24H2) ARM64",
                editionName: "Home China (24H2) ARM64",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3114"]
            ),
            WindowsProduct(
                id: "3133",
                name: "Windows 11 Pro China (24H2) ARM64",
                editionName: "Pro China (24H2) ARM64",
                build: "Build 26100.1742",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3115"]
            ),
            WindowsProduct(
                id: "3265",
                name: "Windows 11 Insider Preview (25H2) ARM64",
                editionName: "Insider Preview (25H2) ARM64",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3262"]
            ),
            WindowsProduct(
                id: "3266",
                name: "Windows 11 Home China (25H2) ARM64",
                editionName: "Home China (25H2) ARM64",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3263"]
            ),
            WindowsProduct(
                id: "3267",
                name: "Windows 11 Pro China (25H2) ARM64",
                editionName: "Pro China (25H2) ARM64",
                build: "Build 26200.6584",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3264"]
            ),
            WindowsProduct(
                id: "3324",
                name: "Windows 11 Insider Preview (25H2 Refresh) ARM64",
                editionName: "Insider Preview (25H2 Refresh) ARM64",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3321", "3265"]
            ),
            WindowsProduct(
                id: "3325",
                name: "Windows 11 Home China (25H2 Refresh) ARM64",
                editionName: "Home China (25H2 Refresh) ARM64",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3322"]
            ),
            WindowsProduct(
                id: "3326",
                name: "Windows 11 Pro China (25H2 Refresh) ARM64",
                editionName: "Pro China (25H2 Refresh) ARM64",
                build: "Build 26200 Refresh",
                category: .windows11,
                badge: .arm64,
                architectures: [.arm64],
                isSecondaryArchitectureVariant: true,
                relatedIDs: ["3323"]
            ),

            // --- Windows 10 ---
            WindowsProduct(
                id: "2618",
                name: "Windows 10 Home / Pro (22H2)",
                editionName: "Home / Pro (22H2)",
                build: "Build 19045.2965",
                category: .windows10,
                badge: .stable,
                architectures: [.x64, .x86],
                relatedIDs: ["3113", "win10-ent-ltsc-2021"]
            ),
            WindowsProduct(
                id: "win10-ent-ltsc-2021",
                name: "Windows 10 Enterprise LTSC (2021)",
                editionName: "Enterprise LTSC (2021)",
                build: "Build 19044.1288",
                category: .windows10,
                badge: .ltsc,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-download.microsoft.com/download/db/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195404",
                relatedIDs: ["2618"]
            ),
            WindowsProduct(
                id: "2378",
                name: "Windows 10 Home China (22H2)",
                editionName: "Home China (22H2)",
                build: "Build 19045.2006",
                category: .windows10,
                badge: .eol,
                architectures: [.x64]
            ),

            // --- Windows Server ---
            WindowsProduct(
                id: "server-2025",
                name: "Windows Server 2025",
                editionName: "2025",
                build: "Build 26100",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?linkid=2289945"
            ),
            WindowsProduct(
                id: "server-2022",
                name: "Windows Server 2022",
                editionName: "2022",
                build: "Build 20348",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195280"
            ),
            WindowsProduct(
                id: "server-2019",
                name: "Windows Server 2019",
                editionName: "2019",
                build: "Build 17763",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                directISOURL: "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
                evalURL: "https://go.microsoft.com/fwlink/p/?LinkID=2195167"
            ),
            WindowsProduct(
                id: "server-2016",
                name: "Windows Server 2016",
                editionName: "2016",
                build: "Build 14393",
                category: .windowsServer,
                badge: .server,
                architectures: [.x64],
                isEvaluation: true,
                evalURL: "https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016"
            ),

            // --- Windows 8 ---
            WindowsProduct(
                id: "52",
                name: "Windows 8.1",
                editionName: "8.1 (Pro / Core)",
                build: "Build 9600.17415",
                category: .windows8,
                badge: .legacy,
                architectures: [.x64, .x86],
                relatedIDs: ["2618"]
            )
        ]
    }

    /// Returns all catalog products belonging to a given category.
    public func products(for category: WindowsCategory) -> [WindowsProduct] {
        allProducts.filter { $0.category == category }
    }

    /// Returns primary selectable editions for a category, filtering out secondary arch variants.
    public func editions(for category: WindowsCategory) -> [WindowsProduct] {
        allProducts.filter { product in
            product.category == category && !product.isSecondaryArchitectureVariant
        }
    }

    /// Resolves the architecture-specific variant of a product (e.g. mapping to ARM64 equivalent).
    public func resolveProduct(for product: WindowsProduct, architecture: WindowsArchitecture) -> WindowsProduct {
        if architecture == .arm64, let armID = product.arm64EquivalentID, let armProduct = findProduct(id: armID) {
            return armProduct
        }
        return product
    }

    /// Finds a product in the catalog by its unique identifier.
    public func findProduct(id: String) -> WindowsProduct? {
        allProducts.first { $0.id == id }
    }

    /// Searches the catalog by product name, edition, build number, or category.
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
