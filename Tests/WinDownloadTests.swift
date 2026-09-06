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
}
