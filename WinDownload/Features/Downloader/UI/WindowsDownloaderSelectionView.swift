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
                    selectorsSection
                    detailsCard
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
                        Text("\(coordinator.selectedArchitecture.shortName) • \(coordinator.selectedLanguage.displayName)" + (coordinator.showExpertDetails ? " • ID: \(coordinator.effectiveSelectedProduct.id)" : ""))
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
                    .disabled(coordinator.hasLowDiskSpaceWarning || coordinator.isResolvingLink)
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

    private var selectorsSection: some View {
        StatusCard(tone: .subtle, density: .regular) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.2.square")
                        .foregroundStyle(.tint)
                    Text("Select Release & Target System")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }

                // Row 1: Two dropdowns next to each other (Version & Edition)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Version", systemImage: "window.badge.magnifyingglass")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)

                        Picker("", selection: $coordinator.selectedCategory) {
                            ForEach(WindowsCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Edition", systemImage: "sparkles")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)

                        Picker("", selection: $coordinator.selectedProduct) {
                            ForEach(coordinator.availableEditions) { prod in
                                Text(coordinator.showExpertDetails ? "\(prod.editionName) [ID: \(prod.id)]" : prod.editionName).tag(prod)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                }

                Divider()

                // Row 2: Two dropdowns next to each other (Architecture & Language)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Architecture", systemImage: "cpu")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)

                        Picker("", selection: $coordinator.selectedArchitecture) {
                            ForEach(coordinator.availableArchitectures) { arch in
                                Text(arch.displayName(expertMode: coordinator.showExpertDetails)).tag(arch)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Label("Language", systemImage: "globe")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            if coordinator.isLoadingLanguages {
                                ProgressView()
                                    .controlSize(.mini)
                            }
                        }

                        Picker("", selection: $coordinator.selectedLanguage) {
                            ForEach(coordinator.availableLanguages) { lang in
                                Text(coordinator.showExpertDetails && !lang.id.isEmpty ? "\(lang.displayName) [SKU: \(lang.id)]" : lang.displayName).tag(lang)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .disabled(coordinator.isLoadingLanguages)
                    }
                }
            }
        }
    }

    private var detailsCard: some View {
        StatusCard(tone: .neutral, density: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.tint)
                    Text("Download Information")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if coordinator.showExpertDetails {
                        Text("EXPERT")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                Divider()

                // Info 1: Windows Edition
                infoRow(icon: "sparkles", iconColor: .blue, label: "Edition") {
                    HStack(spacing: 8) {
                        Text(coordinator.selectedProduct.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        badgeView(for: coordinator.selectedProduct.badge)
                    }
                }

                Divider()

                // Info 2: Windows Build Version
                infoRow(icon: "tag.fill", iconColor: .purple, label: "Build") {
                    Text(coordinator.selectedProduct.build)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                Divider()

                // Info 3: Architecture
                infoRow(icon: "cpu.fill", iconColor: .indigo, label: "Architecture") {
                    Text(coordinator.selectedArchitecture.displayName(expertMode: coordinator.showExpertDetails))
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }

                Divider()

                // Info 4: Language
                infoRow(icon: "globe", iconColor: .teal, label: "Language") {
                    HStack(spacing: 6) {
                        Text(coordinator.selectedLanguage.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        if coordinator.isLoadingLanguages {
                            ProgressView()
                                .controlSize(.mini)
                        }
                    }
                }

                if coordinator.showExpertDetails {
                    let effectiveProduct = coordinator.effectiveSelectedProduct

                    Divider()

                    infoRow(icon: "number.square.fill", iconColor: .orange, label: "Product ID") {
                        HStack(spacing: 6) {
                            Text(effectiveProduct.id)
                                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                            if let armID = coordinator.selectedProduct.arm64EquivalentID {
                                Text(coordinator.selectedArchitecture == .arm64 ? "(ARM64 variant of \(coordinator.selectedProduct.id))" : "(ARM64 ID: \(armID))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()

                    infoRow(icon: "shippingbox.fill", iconColor: .indigo, label: "Channel") {
                        Text(effectiveProduct.channelDescription)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }

                    Divider()

                    infoRow(icon: "server.rack", iconColor: .blue, label: "CDN Source") {
                        Text(effectiveProduct.isEvaluation ? "Microsoft Direct Azure DB CDN" : "Microsoft Official Catalog API")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }

                    if !effectiveProduct.relatedIDs.isEmpty {
                        Divider()

                        infoRow(icon: "point.3.filled.connected.trianglepath.dotted", iconColor: .purple, label: "Related IDs") {
                            Text(effectiveProduct.relatedIDs.joined(separator: ", "))
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider()

                // Info 5: Destination Folder
                infoRow(icon: "folder.fill", iconColor: .orange, label: "Save To") {
                    HStack {
                        Text(coordinator.destinationDirectory.path)
                            .font(.system(.subheadline, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .help(coordinator.destinationDirectory.path)

                        Spacer()

                        Button("Change...") {
                            selectDestinationFolder()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }

                Divider()

                // Info 7: Storage & Disk Space
                infoRow(
                    icon: coordinator.hasLowDiskSpaceWarning ? "exclamationmark.triangle.fill" : "internaldrive.fill",
                    iconColor: coordinator.hasLowDiskSpaceWarning ? .orange : .mint,
                    label: "Storage"
                ) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(coordinator.availableDiskSpaceText)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(coordinator.hasLowDiskSpaceWarning ? .orange : .primary)
                            Text("(~6 GB needed for ISO)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if coordinator.hasLowDiskSpaceWarning {
                            Text("Low disk space warning: Free up space before starting download.")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }

    /// Renders a labeled metadata row with a leading icon.
    private func infoRow<Content: View>(
        icon: String,
        iconColor: Color = .secondary,
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .center, spacing: 14) {
            Label {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 18)
            }
            .frame(width: 130, alignment: .leading)

            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// Renders a color-coded status badge tag for a Windows release.
    private func badgeView(for badge: WindowsBadge) -> some View {
        let color: Color
        switch badge {
        case .latest: color = .green
        case .stable: color = .blue
        case .ltsc: color = .cyan
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

    /// Presents a directory chooser dialog to select the destination folder.
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
