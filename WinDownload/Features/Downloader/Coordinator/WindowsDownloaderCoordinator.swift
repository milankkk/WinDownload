import SwiftUI
import Combine

public enum DownloaderScreen: Equatable {
    case selection
    case downloading
    case summary(fileURL: URL, fileSize: Int64, sha256: String?)
}

@MainActor
public final class WindowsDownloaderCoordinator: ObservableObject {
    // Catalog & Filter
    @Published public var selectedCategory: WindowsCategory = .windows11 {
        didSet {
            if let first = availableEditions.first {
                selectedProduct = first
            }
        }
    }
    @Published public var searchQuery: String = ""
    @Published public var selectedProduct: WindowsProduct {
        didSet {
            updateArchitectureForSelectedProduct()
            loadLanguagesForSelectedProduct()
        }
    }
    @Published public var availableLanguages: [WindowsLanguage] = []
    @Published public var selectedLanguage: WindowsLanguage = .fallbackEnglish
    @Published public var selectedArchitecture: WindowsArchitecture = .x64 {
        didSet {
            if oldValue != selectedArchitecture {
                loadLanguagesForSelectedProduct()
            }
        }
    }
    @Published public var isLoadingLanguages: Bool = false
    @Published public var languageError: String? = nil

    public var availableEditions: [WindowsProduct] {
        WindowsCatalog.shared.editions(for: selectedCategory)
    }

    public var availableArchitectures: [WindowsArchitecture] {
        selectedProduct.architectures
    }

    public var effectiveSelectedProduct: WindowsProduct {
        WindowsCatalog.shared.resolveProduct(for: selectedProduct, architecture: selectedArchitecture)
    }

    // Destination Directory & Space
    @Published public var destinationDirectory: URL
    @Published public var availableDiskSpaceText: String = ""
    @Published public var hasLowDiskSpaceWarning: Bool = false

    // Active Screen & Downloader Engine
    @Published public var currentScreen: DownloaderScreen = .selection
    @Published public var isOptionsPresented: Bool = false
    @Published public var isResolvingLink: Bool = false
    @Published public var resolutionError: String? = nil

    // Options
    @Published public var autoVerifyChecksum: Bool = true
    @Published public var enableNotifications: Bool = true
    @Published public var showExpertDetails: Bool = UserDefaults.standard.bool(forKey: "showExpertDetails") {
        didSet {
            UserDefaults.standard.set(showExpertDetails, forKey: "showExpertDetails")
        }
    }

    public let downloadEngine = WindowsDownloadEngine()
    private var cancellables = Set<AnyCancellable>()
    private var activeResolvedOption: ResolvedDownloadOption?

    public init() {
        let defaultCatalog = WindowsCatalog.shared
        let initialProduct = defaultCatalog.editions(for: .windows11).first ?? defaultCatalog.allProducts[0]
        self.selectedProduct = initialProduct

        let defaultDownloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Downloads")
        self.destinationDirectory = defaultDownloads

        // Set recommended architecture for current host
        if initialProduct.architectures.contains(WindowsArchitecture.currentHostRecommended) {
            self.selectedArchitecture = WindowsArchitecture.currentHostRecommended
        } else {
            self.selectedArchitecture = initialProduct.architectures.first ?? .x64
        }

        self.availableLanguages = WindowsLanguage.defaultList

        setupEngineSubscriptions()
        refreshDiskSpace()
        loadLanguagesForSelectedProduct()
    }

    public var filteredProducts: [WindowsProduct] {
        if !searchQuery.isEmpty {
            return WindowsCatalog.shared.search(query: searchQuery)
        }
        return availableEditions
    }

    /// Re-calculates available disk space at the destination directory.
    public func refreshDiskSpace() {
        self.availableDiskSpaceText = DiskSpaceUtility.formattedAvailableSpace(at: destinationDirectory)
        self.hasLowDiskSpaceWarning = !DiskSpaceUtility.hasSufficientSpace(at: destinationDirectory)
    }

    /// Updates the destination download directory and refreshes free disk space.
    public func setDestinationDirectory(_ url: URL) {
        self.destinationDirectory = url
        refreshDiskSpace()
    }

    /// Ensures the selected architecture is valid for the current product.
    private func updateArchitectureForSelectedProduct() {
        let supported = availableArchitectures
        if !supported.contains(selectedArchitecture) {
            if supported.contains(WindowsArchitecture.currentHostRecommended) {
                selectedArchitecture = WindowsArchitecture.currentHostRecommended
            } else {
                selectedArchitecture = supported.first ?? .x64
            }
        }
    }

    /// Fetches official language SKUs for the selected product and architecture.
    public func loadLanguagesForSelectedProduct() {
        isLoadingLanguages = true
        languageError = nil
        updateArchitectureForSelectedProduct()

        let effectiveProduct = WindowsCatalog.shared.resolveProduct(for: selectedProduct, architecture: selectedArchitecture)

        Task {
            do {
                let langs = try await WindowsISOResolver.shared.resolveLanguages(for: effectiveProduct)
                self.availableLanguages = langs

                // Preserve English if available
                if let matched = langs.first(where: { $0.englishName.localizedCaseInsensitiveContains("English") && !$0.englishName.localizedCaseInsensitiveContains("International") }) {
                    self.selectedLanguage = matched
                } else if let first = langs.first {
                    self.selectedLanguage = first
                }
            } catch {
                self.languageError = error.localizedDescription
                self.availableLanguages = WindowsLanguage.defaultList
            }
            self.isLoadingLanguages = false
        }
    }

    /// Resolves the download link and starts the download engine.
    public func startDownloadWorkflow() {
        isResolvingLink = true
        resolutionError = nil
        currentScreen = .downloading

        Task {
            do {
                let option = try await WindowsISOResolver.shared.resolveDownloadLink(
                    for: selectedProduct,
                    language: selectedLanguage,
                    architecture: selectedArchitecture
                )
                self.activeResolvedOption = option
                self.isResolvingLink = false

                self.downloadEngine.startDownload(
                    from: option.uri,
                    destinationDirectory: self.destinationDirectory,
                    customFileName: option.fileName,
                    verifyChecksum: self.autoVerifyChecksum
                )
            } catch {
                self.isResolvingLink = false
                self.resolutionError = error.localizedDescription
            }
        }
    }

    /// Pauses the ongoing download.
    public func pauseDownload() {
        downloadEngine.pause()
    }

    /// Resumes a paused download.
    public func resumeDownload() {
        guard let option = activeResolvedOption else { return }
        downloadEngine.resume(
            destinationDirectory: destinationDirectory,
            originalURI: option.uri
        )
    }

    /// Cancels the active download and returns to the selection screen.
    public func cancelDownload() {
        downloadEngine.cancel()
        currentScreen = .selection
        activeResolvedOption = nil
        isResolvingLink = false
    }

    /// Resets the downloader engine and returns to the selection screen.
    public func returnToSelection() {
        downloadEngine.reset()
        currentScreen = .selection
        activeResolvedOption = nil
        isResolvingLink = false
        refreshDiskSpace()
    }

    /// Subscribes to download engine state changes and completion notifications.
    private func setupEngineSubscriptions() {
        downloadEngine.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        downloadEngine.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .completed(let url, let size, let hash):
                    self.currentScreen = .summary(fileURL: url, fileSize: size, sha256: hash)
                    if self.enableNotifications {
                        NotificationsManager.shared.postDownloadCompleted(
                            fileName: url.lastPathComponent,
                            fileURL: url
                        )
                    }
                case .failed(let msg):
                    self.resolutionError = msg
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
