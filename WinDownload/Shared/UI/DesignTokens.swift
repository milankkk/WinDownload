import SwiftUI

public enum WinDownloadVisualMode {
    case liquidGlass
    case legacy
}

/// Resolves the visual style mode depending on the macOS version.
public func currentWinDownloadVisualMode() -> WinDownloadVisualMode {
    if #available(macOS 26.0, *) {
        return .liquidGlass
    }
    return .legacy
}

public enum WinDownloadDesignTokens {
    public static let windowWidth: CGFloat = 560
    public static let windowHeight: CGFloat = 760

    public static let contentHorizontalPadding: CGFloat = 18
    public static let contentVerticalPadding: CGFloat = 16
    public static let contentSectionSpacing: CGFloat = 14
    public static let sectionGroupSpacing: CGFloat = 18

    public static let panelInnerPadding: CGFloat = 14
    public static let statusCardCompactPadding: CGFloat = 10

    public static let bottomBarHorizontalPadding: CGFloat = 18
    public static let bottomBarVerticalPadding: CGFloat = 14
    public static let bottomBarContentSpacing: CGFloat = 12
    public static let dockedBarMinHeight: CGFloat = 84

    /// Returns the standard panel corner radius for the given visual mode.
    public static func panelCornerRadius(for mode: WinDownloadVisualMode) -> CGFloat {
        switch mode {
        case .liquidGlass: return 14
        case .legacy: return 10
        }
    }

    /// Returns the prominent panel corner radius for hero cards.
    public static func prominentPanelCornerRadius(for mode: WinDownloadVisualMode) -> CGFloat {
        switch mode {
        case .liquidGlass: return 16
        case .legacy: return 12
        }
    }

    /// Returns the top corner radius for the docked bottom action bar.
    public static func dockedBarTopCornerRadius(for mode: WinDownloadVisualMode) -> CGFloat {
        switch mode {
        case .liquidGlass: return 14
        case .legacy: return 10
        }
    }
}
