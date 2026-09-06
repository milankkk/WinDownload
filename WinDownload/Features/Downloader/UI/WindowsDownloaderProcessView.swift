import SwiftUI

public struct WindowsDownloaderProcessView: View {
    @ObservedObject var coordinator: WindowsDownloaderCoordinator
    @ObservedObject private var engine: WindowsDownloadEngine

    public init(coordinator: WindowsDownloaderCoordinator) {
        self.coordinator = coordinator
        self._engine = ObservedObject(wrappedValue: coordinator.downloadEngine)
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: WinDownloadDesignTokens.sectionGroupSpacing) {
                    productHeaderCard

                    if let error = coordinator.resolutionError {
                        errorCard(message: error)
                    }

                    progressCard
                    stagesCard
                }
                .padding(.horizontal, WinDownloadDesignTokens.contentHorizontalPadding)
                .padding(.top, WinDownloadDesignTokens.contentVerticalPadding)
                .padding(.bottom, 20)
            }

            BottomActionBar {
                HStack(spacing: 12) {
                    Button(role: .destructive) {
                        coordinator.cancelDownload()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .winDownloadSecondaryButtonStyle()

                    if case .downloading(let isPaused) = engine.status {
                        Button {
                            if isPaused {
                                coordinator.resumeDownload()
                            } else {
                                coordinator.pauseDownload()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                Text(isPaused ? "Resume" : "Pause")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .winDownloadPrimaryButtonStyle()
                    }
                }
            }
        }
    }

    private var productHeaderCard: some View {
        StatusCard(tone: .subtle, density: .compact) {
            HStack(spacing: 14) {
                Image(systemName: "opticaldisc.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.tint)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coordinator.selectedProduct.name)
                        .font(.headline)
                    Text("\(coordinator.selectedArchitecture.shortName) • \(coordinator.selectedLanguage.englishName) • \(coordinator.selectedProduct.build)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private func errorCard(message: String) -> some View {
        StatusCard(tone: .error, density: .compact) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Download Error")
                        .font(.subheadline.weight(.semibold))
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Retry") {
                    coordinator.startDownloadWorkflow()
                }
                .controlSize(.small)
            }
        }
    }

    private var progressCard: some View {
        StatusCard(tone: .neutral, density: .regular) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(stageHeadline)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if coordinator.isResolvingLink {
                        ProgressView()
                            .controlSize(.small)
                    } else if engine.progress.totalExpectedBytes > 0 {
                        Text(String(format: "%.0f%%", engine.progress.fractionCompleted * 100))
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.tint)
                    }
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.18))
                            .frame(height: 10)

                        if coordinator.isResolvingLink {
                            Capsule()
                                .fill(Color.accentColor.opacity(0.6))
                                .frame(width: geo.size.width * 0.25, height: 10)
                        } else {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.accentColor.opacity(0.8), Color.accentColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: max(8, geo.size.width * CGFloat(engine.progress.fractionCompleted)),
                                    height: 10
                                )
                                .animation(.linear(duration: 0.2), value: engine.progress.fractionCompleted)
                        }
                    }
                }
                .frame(height: 10)

                // Statistics
                if !coordinator.isResolvingLink {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Transferred")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(engine.progress.formattedTransferred)
                                .font(.caption.monospacedDigit().weight(.medium))
                        }

                        Spacer()

                        VStack(alignment: .center, spacing: 2) {
                            Text("Speed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(engine.progress.formattedSpeed)
                                .font(.caption.monospacedDigit().weight(.medium))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Time Remaining")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(engine.progress.formattedTimeRemaining)
                                .font(.caption.monospacedDigit().weight(.medium))
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var stageHeadline: String {
        if coordinator.isResolvingLink {
            return "Resolving official download link..."
        }
        switch engine.status {
        case .downloading(let isPaused):
            return isPaused ? "Download Paused" : "Downloading Windows ISO..."
        case .verifying:
            return "Verifying file integrity..."
        case .completed:
            return "Download completed!"
        case .failed:
            return "Download interrupted"
        default:
            return "Preparing download..."
        }
    }

    private var stagesCard: some View {
        StatusCard(tone: .neutral, density: .regular) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Workflow Stages")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)

                ForEach(DownloadWorkflowStage.allCases) { stage in
                    stageRow(for: stage)
                }
            }
        }
    }

    private func stageRow(for stage: DownloadWorkflowStage) -> some View {
        let isCurrent: Bool
        let isCompleted: Bool

        if coordinator.isResolvingLink {
            isCurrent = stage == .resolvingLink
            isCompleted = false
        } else {
            isCompleted = stage.orderIndex < engine.currentStage.orderIndex
            isCurrent = stage == engine.currentStage
        }

        return HStack(spacing: 10) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 14))
            } else if isCurrent {
                ProgressView()
                    .controlSize(.small)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.secondary.opacity(0.5))
                    .font(.system(size: 14))
            }

            Text(stage.rawValue)
                .font(.subheadline)
                .foregroundStyle(isCurrent ? .primary : (isCompleted ? .primary : .secondary))

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
