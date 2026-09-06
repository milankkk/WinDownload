import SwiftUI

public struct BottomActionBar<Content: View>: View {
    @ViewBuilder private let content: Content

    /// Creates a docked bottom bar containing action controls and status indicators.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: WinDownloadDesignTokens.bottomBarContentSpacing) {
            content
        }
        .padding(.horizontal, WinDownloadDesignTokens.bottomBarHorizontalPadding)
        .padding(.vertical, WinDownloadDesignTokens.bottomBarVerticalPadding)
        .frame(maxWidth: .infinity, minHeight: WinDownloadDesignTokens.dockedBarMinHeight, alignment: .top)
        .winDownloadDockedBarSurface()
    }
}
