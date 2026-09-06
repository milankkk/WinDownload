// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WinDownload",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "WinDownload",
            targets: ["WinDownload"]
        ),
        .library(
            name: "WinDownloadCore",
            targets: ["WinDownloadCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WinDownloadCore",
            path: "WinDownload/Core"
        ),
        .executableTarget(
            name: "WinDownload",
            dependencies: ["WinDownloadCore"],
            path: "WinDownload",
            exclude: ["Core", "App/Info.plist", "App/WinDownload.entitlements"],
            sources: [
                "App",
                "Shared",
                "Features"
            ]
        ),
        .testTarget(
            name: "WinDownloadTests",
            dependencies: ["WinDownloadCore"],
            path: "Tests"
        )
    ]
)
