import XCTest
@testable import WinDownloadCore

final class WinDownloadTests: XCTestCase {
    func testCatalogHasAllCategories() {
        let catalog = WindowsCatalog.shared
        for category in WindowsCategory.allCases {
            let products = catalog.products(for: category)
            XCTAssertFalse(products.isEmpty, "Category \(category.rawValue) should have products")
        }
    }

    func testProductLookupByID() {
        let catalog = WindowsCatalog.shared
        let win11 = catalog.findProduct(id: "3262")
        XCTAssertNotNil(win11)
        XCTAssertEqual(win11?.category, .windows11)
        XCTAssertEqual(win11?.badge, .latest)
    }

    func testProductSearch() {
        let catalog = WindowsCatalog.shared
        let results = catalog.search(query: "server 2025")
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.id, "server-2025")
    }

    func testArchitectureDetection() {
        XCTAssertEqual(WindowsArchitecture.from(string: "Win11_24H2_Arm64.iso"), .arm64)
        XCTAssertEqual(WindowsArchitecture.from(string: "Win11_25H2_x64.iso"), .x64)
        XCTAssertEqual(WindowsArchitecture.from(string: "Win10_22H2_x86.iso"), .x86)
    }

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

    func testResolvedDownloadOptionFileNameExtraction() {
        let opt = ResolvedDownloadOption(
            uri: "https://software.download.prss.microsoft.com/dbazure/Win11_25H2_English_x64.iso?t=12345",
            architecture: .x64
        )
        XCTAssertEqual(opt.fileName, "Win11_25H2_English_x64.iso")
    }

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
}
