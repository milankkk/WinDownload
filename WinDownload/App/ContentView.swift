import SwiftUI

public struct ContentView: View {
    @StateObject private var coordinator = WindowsDownloaderCoordinator()

    /// Initializes the root content view.
    public init() {}

    public var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .selection:
                WindowsDownloaderSelectionView(coordinator: coordinator)
                    .transition(.opacity)
            case .downloading:
                WindowsDownloaderProcessView(coordinator: coordinator)
                    .transition(.opacity)
            case .summary(let fileURL, let fileSize, let sha256):
                WindowsDownloaderSummaryView(
                    coordinator: coordinator,
                    fileURL: fileURL,
                    fileSize: fileSize,
                    sha256: sha256
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: coordinator.currentScreen)
        .frame(
            width: WinDownloadDesignTokens.windowWidth,
            height: WinDownloadDesignTokens.windowHeight
        )
        .sheet(isPresented: $coordinator.isOptionsPresented) {
            WindowsDownloaderOptionsSheet(coordinator: coordinator)
        }
        .onAppear {
            NotificationsManager.shared.requestPermission()
        }
    }
}
