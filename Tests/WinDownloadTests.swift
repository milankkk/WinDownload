import XCTest
@testable import WinDownloadCore

final class WinDownloadTests: XCTestCase {
    /// Verifies that all top-level categories have available catalog items.
    func testCatalogHasAllCategories() {
        let catalog = WindowsCatalog.shared
        for category in WindowsCategory.allCases {
            let products = catalog.products(for: category)
            XCTAssertFalse(products.isEmpty, "Category \(category.rawValue) should have products")
        }
    }

    /// Verifies looking up a product by its unique product ID.
    func testProductLookupByID() {
        let catalog = WindowsCatalog.shared
        let win11 = catalog.findProduct(id: "3262")
        XCTAssertNotNil(win11)
        XCTAssertEqual(win11?.category, .windows11)
        XCTAssertEqual(win11?.badge, .latest)
    }

    /// Verifies catalog text search query matching.
    func testProductSearch() {
        let catalog = WindowsCatalog.shared
        let results = catalog.search(query: "server 2025")
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.id, "server-2025")
    }

    /// Verifies string-based architecture inference.
    func testArchitectureDetection() {
        XCTAssertEqual(WindowsArchitecture.from(string: "Win11_24H2_Arm64.iso"), .arm64)
        XCTAssertEqual(WindowsArchitecture.from(string: "Win11_25H2_x64.iso"), .x64)
        XCTAssertEqual(WindowsArchitecture.from(string: "Win10_22H2_x86.iso"), .x86)
    }

    /// Verifies formatting of speed, transferred bytes, and time remaining.
    func testProgressMetricsFormatting() {
        var metrics = DownloadProgressMetrics()
        metrics.bytesDownloaded = 2_147_483_648 // 2 GB
        metrics.totalExpectedBytes = 4_294_967_296 // 4 GB
        metrics.fractionCompleted = 0.5
        metrics.speedMBps = 25.5
        metrics.timeRemainingSeconds = 84 // 1m 24s

        XCTAssertEqual(metrics.formattedSpeed, "25.5 MB/s")
        XCTAssertEqual(metrics.formattedTransferred, "2.00 GB / 4.00 GB")
        XCTAssertEqual(metrics.formattedTimeRemaining, "1m 24s remaining")
    }

    /// Verifies filename extraction from query-string URIs.
    func testResolvedDownloadOptionFileNameExtraction() {
        let opt = ResolvedDownloadOption(
            uri: "https://software.download.prss.microsoft.com/dbazure/Win11_25H2_English_x64.iso?t=12345",
            architecture: .x64
        )
        XCTAssertEqual(opt.fileName, "Win11_25H2_English_x64.iso")
    }

    /// Verifies live language and download link resolution against Microsoft APIs.
    func testLiveResolution() async throws {
        let product = WindowsCatalog.shared.allProducts[0]
        print("Testing product: \(product.name) (ID: \(product.id))")
        let langs = try await WindowsISOResolver.shared.resolveLanguages(for: product)
        print("Resolved languages count: \(langs.count)")
        XCTAssertFalse(langs.isEmpty)
        guard let english = langs.first(where: { $0.englishName.localizedCaseInsensitiveContains("English") && !$0.englishName.localizedCaseInsensitiveContains("International") }) else {
            XCTFail("No English language found")
            return
        }
        print("Testing English SKU ID: \(english.id)")
        let opt = try await WindowsISOResolver.shared.resolveDownloadLink(for: product, language: english, architecture: product.architectures.first ?? .x64)
        print("Resolved option: \(opt.uri)")
        XCTAssertFalse(opt.uri.isEmpty)
    }

    /// Tests download engine network streaming, progress reporting, and cancellation.
    @MainActor
    func testDownloadEngineExecution() async throws {
        let engine = WindowsDownloadEngine()
        let tempDir = FileManager.default.temporaryDirectory
        print("Starting engine download to \(tempDir.path)...")
        // Use a test URL
        engine.startDownload(
            from: "https://speed.cloudflare.com/__down?bytes=10000000", // 10MB test file
            destinationDirectory: tempDir,
            customFileName: "test_download.bin",
            verifyChecksum: false
        )

        var sawProgress = false
        for _ in 0..<30 {
            try await Task.sleep(nanoseconds: 200_000_000)
            if engine.progress.bytesDownloaded > 0 {
                print("Progress bytes downloaded: \(engine.progress.bytesDownloaded), speed: \(engine.progress.speedMBps) MB/s")
                sawProgress = true
                break
            }
        }
        engine.cancel()
        XCTAssertTrue(sawProgress, "Engine should receive bytes")
    }

    /// Verifies availability of LTSC editions in Windows 10 and 11 catalogs.
    func testCatalogEditionsAndLTSC() {
        let catalog = WindowsCatalog.shared
        let win11Editions = catalog.editions(for: .windows11)
        let win10Editions = catalog.editions(for: .windows10)

        XCTAssertTrue(win11Editions.contains(where: { $0.badge == .ltsc }), "Windows 11 should have an LTSC edition")
        XCTAssertTrue(win10Editions.contains(where: { $0.badge == .ltsc }), "Windows 10 should have an LTSC edition")

        let win11LTSC = catalog.findProduct(id: "win11-ent-ltsc-2024")
        XCTAssertNotNil(win11LTSC)
        XCTAssertEqual(win11LTSC?.badge, .ltsc)
    }

    /// Verifies direct URL resolution for Enterprise LTSC evaluation ISOs.
    func testLTSCResolution() async throws {
        guard let win11LTSC = WindowsCatalog.shared.findProduct(id: "win11-ent-ltsc-2024") else {
            XCTFail("Missing win11-ent-ltsc-2024 product")
            return
        }
        let option = try await WindowsISOResolver.shared.resolveDownloadLink(
            for: win11LTSC,
            language: WindowsLanguage(id: "eval-en", englishName: "English (US)"),
            architecture: .x64
        )
        XCTAssertTrue(option.uri.contains(".iso"))
        XCTAssertEqual(option.architecture, .x64)
    }

    /// Verifies newly added regional China and preview SKUs and dynamic architecture mapping.
    func testNewProductsAndArchitectureResolution() {
        let catalog = WindowsCatalog.shared

        // Test China 24H2 variants
        let homeChina24 = catalog.findProduct(id: "3114")
        XCTAssertNotNil(homeChina24)
        XCTAssertEqual(homeChina24?.arm64EquivalentID, "3132")
        let homeChina24ARM = catalog.resolveProduct(for: homeChina24!, architecture: .arm64)
        XCTAssertEqual(homeChina24ARM.id, "3132")

        let proChina24 = catalog.findProduct(id: "3115")
        XCTAssertNotNil(proChina24)
        XCTAssertEqual(proChina24?.arm64EquivalentID, "3133")
        let proChina24ARM = catalog.resolveProduct(for: proChina24!, architecture: .arm64)
        XCTAssertEqual(proChina24ARM.id, "3133")

        // Test Preview 25H2 ARM64 pairing
        let preview25 = catalog.findProduct(id: "3262")
        XCTAssertNotNil(preview25)
        XCTAssertEqual(preview25?.arm64EquivalentID, "3265")
        let preview25ARM = catalog.resolveProduct(for: preview25!, architecture: .arm64)
        XCTAssertEqual(preview25ARM.id, "3265")

        // Test 25H2 Refresh variants
        let refresh25 = catalog.findProduct(id: "3321")
        XCTAssertNotNil(refresh25)
        XCTAssertEqual(refresh25?.arm64EquivalentID, "3324")
        let refresh25ARM = catalog.resolveProduct(for: refresh25!, architecture: .arm64)
        XCTAssertEqual(refresh25ARM.id, "3324")

        // Test that secondary ARM64 variants are filtered from primary editions list
        let win11Editions = catalog.editions(for: .windows11)
        XCTAssertFalse(win11Editions.contains(where: { $0.id == "3131" }))
        XCTAssertFalse(win11Editions.contains(where: { $0.id == "3132" }))
        XCTAssertFalse(win11Editions.contains(where: { $0.id == "3133" }))
        XCTAssertFalse(win11Editions.contains(where: { $0.id == "3265" }))
        XCTAssertFalse(win11Editions.contains(where: { $0.id == "3324" }))

        // But primary editions ARE in the editions list
        XCTAssertTrue(win11Editions.contains(where: { $0.id == "3113" }))
        XCTAssertTrue(win11Editions.contains(where: { $0.id == "3114" }))
        XCTAssertTrue(win11Editions.contains(where: { $0.id == "3115" }))
        XCTAssertTrue(win11Editions.contains(where: { $0.id == "3262" }))
        XCTAssertTrue(win11Editions.contains(where: { $0.id == "3321" }))
    }

    /// Verifies clean and expert architecture display string formats.
    func testArchitectureDisplayModes() {
        XCTAssertEqual(WindowsArchitecture.arm64.displayName, "ARM64")
        XCTAssertEqual(WindowsArchitecture.x64.displayName, "64-bit (x64)")
        XCTAssertEqual(WindowsArchitecture.x86.displayName, "32-bit (x86)")

        XCTAssertTrue(WindowsArchitecture.arm64.displayName(expertMode: true).contains("AArch64"))
        XCTAssertTrue(WindowsArchitecture.x64.displayName(expertMode: true).contains("AMD64"))
        XCTAssertTrue(WindowsArchitecture.x86.displayName(expertMode: true).contains("IA-32"))
    }
}
