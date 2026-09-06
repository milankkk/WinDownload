import SwiftUI

public struct WindowsDownloaderOptionsSheet: View {
    @ObservedObject var coordinator: WindowsDownloaderCoordinator
    @Environment(\.dismiss) private var dismiss

    public init(coordinator: WindowsDownloaderCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Downloader Options")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }

            Divider()

            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $coordinator.autoVerifyChecksum) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Verify SHA-256 Checksum")
                            .font(.body.weight(.medium))
                        Text("Automatically computes cryptographic hash when the ISO download finishes.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.checkbox)

                Divider()

                Toggle(isOn: $coordinator.enableNotifications) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("System Notifications")
                            .font(.body.weight(.medium))
                        Text("Show a banner alert when large downloads complete in the background.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .toggleStyle(.checkbox)

                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Connection Strategy")
                        .font(.body.weight(.medium))
                    Text("WinDownload connects directly to Microsoft's official CDN infrastructure, using MSDL's distributed cache as an automatic fallback.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 440, height: 320)
    }
}
