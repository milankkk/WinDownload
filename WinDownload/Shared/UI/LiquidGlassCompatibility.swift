import SwiftUI

public enum WinDownloadSurfaceTone {
    case neutral
    case subtle
    case info
    case success
    case warning
    case error
    case active

    func fallbackFillColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .neutral:
            return colorScheme == .dark ? Color.white.opacity(0.065) : Color.black.opacity(0.038)
        case .subtle:
            return colorScheme == .dark ? Color.white.opacity(0.060) : Color.black.opacity(0.032)
        case .info:
            return Color.blue.opacity(0.12)
        case .success:
            return Color.green.opacity(0.12)
        case .warning:
            return Color.orange.opacity(0.12)
        case .error:
            return Color.red.opacity(0.12)
        case .active:
            return Color.accentColor.opacity(0.14)
        }
    }

    func fallbackStrokeColor(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .neutral:
            return colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)
        case .subtle:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
        case .info:
            return Color.blue.opacity(0.35)
        case .success:
            return Color.green.opacity(0.35)
        case .warning:
            return Color.orange.opacity(0.35)
        case .error:
            return Color.red.opacity(0.35)
        case .active:
            return Color.accentColor.opacity(0.40)
        }
    }
}

public struct WinDownloadPanelSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let tone: WinDownloadSurfaceTone
    let cornerRadius: CGFloat?

    public init(tone: WinDownloadSurfaceTone = .neutral, cornerRadius: CGFloat? = nil) {
        self.tone = tone
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        let mode = currentWinDownloadVisualMode()
        let radius = cornerRadius ?? WinDownloadDesignTokens.panelCornerRadius(for: mode)
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        content
            .background(shape.fill(tone.fallbackFillColor(for: colorScheme)))
            .overlay(
                shape.stroke(tone.fallbackStrokeColor(for: colorScheme), lineWidth: 0.8)
            )
    }
}

public struct WinDownloadDockedBarSurfaceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public func body(content: Content) -> some View {
        let mode = currentWinDownloadVisualMode()
        let radius = WinDownloadDesignTokens.dockedBarTopCornerRadius(for: mode)
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: radius,
            style: .continuous
        )

        content
            .background(shape.fill(WinDownloadSurfaceTone.subtle.fallbackFillColor(for: colorScheme)))
            .overlay(
                shape.stroke(WinDownloadSurfaceTone.subtle.fallbackStrokeColor(for: colorScheme), lineWidth: 0.8)
            )
    }
}

public struct WinDownloadPrimaryButtonStyleModifier: ViewModifier {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.accentColor)
            .opacity(isEnabled ? 1.0 : 0.55)
    }
}

public struct WinDownloadSecondaryButtonStyleModifier: ViewModifier {
    let isEnabled: Bool

    public init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    public func body(content: Content) -> some View {
        content
            .buttonStyle(.bordered)
            .controlSize(.large)
            .opacity(isEnabled ? 1.0 : 0.55)
    }
}

public extension View {
    func winDownloadPanelSurface(_ tone: WinDownloadSurfaceTone = .neutral, cornerRadius: CGFloat? = nil) -> some View {
        modifier(WinDownloadPanelSurfaceModifier(tone: tone, cornerRadius: cornerRadius))
    }

    func winDownloadDockedBarSurface() -> some View {
        modifier(WinDownloadDockedBarSurfaceModifier())
    }

    func winDownloadPrimaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(WinDownloadPrimaryButtonStyleModifier(isEnabled: isEnabled))
    }

    func winDownloadSecondaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(WinDownloadSecondaryButtonStyleModifier(isEnabled: isEnabled))
    }
}
