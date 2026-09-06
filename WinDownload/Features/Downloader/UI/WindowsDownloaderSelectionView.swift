import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct WindowsDownloaderSelectionView: View {
    @ObservedObject var coordinator: WindowsDownloaderCoordinator

    public init(coordinator: WindowsDownloaderCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WinDownloadDesignTokens.sectionGroupSpacing) {
                    headerSection
                    categoryPickerSection
                    if !coordinator.searchQuery.isEmpty || coordinator.filteredProducts.count > 1 {
                        searchBarSection
                    }
                    productsSection
                    configurationSection
                }
                .padding(.horizontal, WinDownloadDesignTokens.contentHorizontalPadding)
                .padding(.top, WinDownloadDesignTokens.contentVerticalPadding)
                .padding(.bottom, 20)
            }

            BottomActionBar {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(coordinator.selectedProduct.name)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                        Text("\(coordinator.selectedArchitecture.shortName) • \(coordinator.selectedLanguage.englishName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        coordinator.startDownloadWorkflow()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.circle.fill")
                            Text("Download ISO")
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                    }
                    .winDownloadPrimaryButtonStyle()
                    .disabled(coordinator.hasLowDiskSpaceWarning)
                }
            }
        }
    }

    private var headerSection: some View {
        StatusCard(tone: .subtle, density: .regular) {
            HStack(alignment: .center, spacing: 14) {
                Image(systemName: "opticaldisc.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.tint)
                    .frame(width: 38, height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Windows ISO Downloader")
                        .font(.headline)
                    Text("Official Windows disk images directly from Microsoft CDN")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    coordinator.isOptionsPresented = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14, weight: .medium))
                }
                .winDownloadSecondaryButtonStyle()
                .help("Settings & Options")
            }
        }
    }

    private var categoryPickerSection: some View {
        Picker("Category", selection: $coordinator.selectedCategory) {
            ForEach(WindowsCategory.allCases) { cat in
                Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
            }
        }
        .pickerStyle(.segmented)
    }

    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search Windows releases...", text: $coordinator.searchQuery)
                .textFieldStyle(.plain)
            if !coordinator.searchQuery.isEmpty {
                Button {
                    coordinator.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .winDownloadPanelSurface(.neutral)
    }

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Available Editions")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                ForEach(coordinator.filteredProducts) { product in
                    productCard(for: product)
                }
            }
        }
    }

    private func productCard(for product: WindowsProduct) -> some View {
        let isSelected = coordinator.selectedProduct.id == product.id

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                coordinator.selectedProduct = product
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.6))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(product.name)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)

                        badgeView(for: product.badge)
                    }

                    Text(product.build)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(product.architectures) { arch in
                        Text(arch.shortName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(Color.secondary.opacity(0.12))
                            )
                    }
                }
            }
            .padding(WinDownloadDesignTokens.statusCardCompactPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .winDownloadPanelSurface(isSelected ? .active : .neutral)
        }
        .buttonStyle(.plain)
    }

    private func badgeView(for badge: WindowsBadge) -> some View {
        let color: Color
        switch badge {
        case .latest: color = .green
        case .stable: color = .blue
        case .arm64: color = .purple
        case .server: color = .orange
        case .eval: color = .yellow
        case .eol, .legacy: color = .secondary
        }

        return Text(badge.rawValue)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(color.opacity(0.14))
            )
            .overlay(
                Capsule().stroke(color.opacity(0.35), lineWidth: 0.6)
            )
    }

    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Download Settings")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            StatusCard(tone: .neutral, density: .regular) {
                VStack(spacing: 12) {
                    // Language
                    HStack {
                        Label("Language", systemImage: "globe")
                            .font(.subheadline)
                        Spacer()
                        if coordinator.isLoadingLanguages {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Picker("", selection: $coordinator.selectedLanguage) {
                                ForEach(coordinator.availableLanguages) { lang in
                                    Text(lang.displayName).tag(lang)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: 220)
                        }
                    }

                    Divider()

                    // Architecture
                    HStack {
                        Label("Architecture", systemImage: "cpu")
                            .font(.subheadline)
                        Spacer()
                        Picker("", selection: $coordinator.selectedArchitecture) {
                            ForEach(coordinator.selectedProduct.architectures) { arch in
                                Text(arch.shortName).tag(arch)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 180)
                    }

                    Divider()

                    // Destination Folder
                    HStack {
                        Label("Save To", systemImage: "folder")
                            .font(.subheadline)
                        Spacer()
                        Button {
                            selectDestinationFolder()
                        } label: {
                            HStack(spacing: 6) {
                                Text(coordinator.destinationDirectory.lastPathComponent)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }

                    // Disk Space Info
                    HStack {
                        Image(systemName: coordinator.hasLowDiskSpaceWarning ? "exclamationmark.triangle.fill" : "internaldrive")
                            .foregroundStyle(coordinator.hasLowDiskSpaceWarning ? .orange : .secondary)
                        Text(coordinator.availableDiskSpaceText)
                            .font(.caption)
                            .foregroundStyle(coordinator.hasLowDiskSpaceWarning ? .orange : .secondary)
                        if coordinator.hasLowDiskSpaceWarning {
                            Text("(At least 9 GB recommended)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func selectDestinationFolder() {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"
        panel.directoryURL = coordinator.destinationDirectory

        if panel.runModal() == .OK, let selectedURL = panel.url {
            coordinator.setDestinationDirectory(selectedURL)
        }
        #endif
    }
}
