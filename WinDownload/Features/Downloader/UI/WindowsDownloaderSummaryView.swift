import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

public struct WindowsDownloaderSummaryView: View {
    @ObservedObject var coordinator: WindowsDownloaderCoordinator
    let fileURL: URL
    let fileSize: Int64
    let sha256: String?

    @State private var isHashCopied: Bool = false

    public init(
        coordinator: WindowsDownloaderCoordinator,
        fileURL: URL,
        fileSize: Int64,
        sha256: String?
    ) {
        self.coordinator = coordinator
        self.fileURL = fileURL
        self.fileSize = fileSize
        self.sha256 = sha256
    }

    private var formattedSize: String {
        let gb = Double(fileSize) / 1_073_741_824.0
        return String(format: "%.2f GB", gb)
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WinDownloadDesignTokens.sectionGroupSpacing) {
                    successHeroCard
                    fileDetailsCard
                    integrationCard
                }
                .padding(.horizontal, WinDownloadDesignTokens.contentHorizontalPadding)
                .padding(.top, WinDownloadDesignTokens.contentVerticalPadding)
                .padding(.bottom, 20)
            }

            BottomActionBar {
                HStack(spacing: 12) {
                    Button {
                        coordinator.returnToSelection()
                    } label: {
                        Text("Download Another ISO")
                            .frame(maxWidth: .infinity)
                    }
                    .winDownloadSecondaryButtonStyle()

                    Button {
                        MacUSBHandoff.revealInFinder(url: fileURL)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "folder.fill")
                            Text("Reveal in Finder")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .winDownloadPrimaryButtonStyle()
                }
            }
        }
    }

    private var successHeroCard: some View {
        StatusCard(tone: .success, density: .regular) {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(.green)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Windows ISO Ready!")
                        .font(.title3.weight(.bold))
                    Text("Your disk image was successfully downloaded and verified.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var fileDetailsCard: some View {
        StatusCard(tone: .neutral, density: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                Text("File Details")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)

                HStack {
                    Text("File Name")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(fileURL.lastPathComponent)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                }

                Divider()

                HStack {
                    Text("Size")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(formattedSize)
                        .font(.subheadline.weight(.medium))
                }

                Divider()

                HStack {
                    Text("Location")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(fileURL.deletingLastPathComponent().path)
                        .font(.caption)
                        .lineLimit(1)
                }

                if let hash = sha256 {
                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("SHA-256 Checksum")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button {
                                copyToClipboard(text: hash)
                                isHashCopied = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isHashCopied = false
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: isHashCopied ? "checkmark" : "doc.on.doc")
                                    Text(isHashCopied ? "Copied" : "Copy")
                                }
                                .font(.caption2)
                            }
                            .buttonStyle(.borderless)
                        }

                        Text(hash)
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .textSelection(.enabled)
                    }
                }
            }
        }
    }

    private var integrationCard: some View {
        StatusCard(tone: .subtle, density: .regular) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "externaldrive.fill.badge.plus")
                        .font(.system(size: 26))
                        .foregroundStyle(Color.accentColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create Bootable USB")
                            .font(.subheadline.weight(.semibold))
                        Text("Write this Windows installer directly to a USB flash drive using macUSB.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                if MacUSBHandoff.isMacUSBInstalled {
                    Button {
                        _ = MacUSBHandoff.openInMacUSB(isoFileURL: fileURL)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.up.forward.app.fill")
                            Text("Open in macUSB")
                        }
                    }
                    .winDownloadSecondaryButtonStyle()
                } else {
                    Text("macUSB is recommended for creating bootable UEFI/BIOS Windows drives on Mac.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// Copies the provided text to the macOS system pasteboard.
    private func copyToClipboard(text: String) {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        #endif
    }
}
