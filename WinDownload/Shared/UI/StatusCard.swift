import SwiftUI

public enum StatusCardDensity {
    case regular
    case compact
}

public struct StatusCard<Content: View>: View {
    public let tone: WinDownloadSurfaceTone
    public let cornerRadius: CGFloat?
    public let density: StatusCardDensity
    private let content: Content

    public init(
        tone: WinDownloadSurfaceTone = .neutral,
        cornerRadius: CGFloat? = nil,
        density: StatusCardDensity = .regular,
        @ViewBuilder content: () -> Content
    ) {
        self.tone = tone
        self.cornerRadius = cornerRadius
        self.density = density
        self.content = content()
    }

    private var paddingValue: CGFloat {
        switch density {
        case .regular:
            return WinDownloadDesignTokens.panelInnerPadding
        case .compact:
            return WinDownloadDesignTokens.statusCardCompactPadding
        }
    }

    public var body: some View {
        content
            .padding(paddingValue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .winDownloadPanelSurface(tone, cornerRadius: cornerRadius)
    }
}
