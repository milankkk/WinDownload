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
    @Published public var selectedCategory: WindowsCategory = .windows11
    @Published public var searchQuery: String = ""
    @Published public var selectedProduct: WindowsProduct {
        didSet {
            loadLanguagesForSelectedProduct()
        }
    }
    @Published public var availableLanguages: [WindowsLanguage] = []
    @Published public var selectedLanguage: WindowsLanguage = .fallbackEnglish
    @Published public var selectedArchitecture: WindowsArchitecture = .x64
    @Published public var isLoadingLanguages: Bool = false
    @Published public var languageError: String? = nil

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

    public let downloadEngine = WindowsDownloadEngine()
    private var cancellables = Set<AnyCancellable>()
    private var activeResolvedOption: ResolvedDownloadOption?

    public init() {
        let defaultCatalog = WindowsCatalog.shared
        let initialProduct = defaultCatalog.products(for: .windows11).first ?? defaultCatalog.allProducts[0]
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
        return WindowsCatalog.shared.products(for: selectedCategory)
    }

    public func refreshDiskSpace() {
        self.availableDiskSpaceText = DiskSpaceUtility.formattedAvailableSpace(at: destinationDirectory)
        self.hasLowDiskSpaceWarning = !DiskSpaceUtility.hasSufficientSpace(at: destinationDirectory)
    }

    public func setDestinationDirectory(_ url: URL) {
        self.destinationDirectory = url
        refreshDiskSpace()
    }

    public func loadLanguagesForSelectedProduct() {
        isLoadingLanguages = true
        languageError = nil

        // Automatically update selected architecture if not supported by new product
        if !selectedProduct.architectures.contains(selectedArchitecture) {
            selectedArchitecture = selectedProduct.architectures.first ?? .x64
        }

        Task {
            do {
                let langs = try await WindowsISOResolver.shared.resolveLanguages(for: selectedProduct)
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

    public func pauseDownload() {
        downloadEngine.pause()
    }

    public func resumeDownload() {
        guard let option = activeResolvedOption else { return }
        downloadEngine.resume(
            destinationDirectory: destinationDirectory,
            originalURI: option.uri
        )
    }

    public func cancelDownload() {
        downloadEngine.cancel()
        currentScreen = .selection
        activeResolvedOption = nil
        isResolvingLink = false
    }

    public func returnToSelection() {
        downloadEngine.reset()
        currentScreen = .selection
        activeResolvedOption = nil
        isResolvingLink = false
        refreshDiskSpace()
    }

    private func setupEngineSubscriptions() {
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
