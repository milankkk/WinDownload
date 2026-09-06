import Foundation
#if canImport(AppKit)
import AppKit

public struct MacUSBHandoff {
    /// Resolves the file URL of the macUSB application if installed.
    private static var macUSBURL: URL? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.kruszoneq.macusb") {
            return url
        }
        let directAppURL = URL(fileURLWithPath: "/Applications/macUSB.app")
        return FileManager.default.fileExists(atPath: directAppURL.path) ? directAppURL : nil
    }

    /// Indicates whether macUSB is available on the local system.
    public static var isMacUSBInstalled: Bool {
        macUSBURL != nil
    }

    /// Hands off the downloaded ISO file to macUSB for bootable drive creation.
    public static func openInMacUSB(isoFileURL: URL) -> Bool {
        guard let appURL = macUSBURL else { return false }
        let config = NSWorkspace.OpenConfiguration()
        config.promptsUserIfNeeded = true
        NSWorkspace.shared.open([isoFileURL], withApplicationAt: appURL, configuration: config, completionHandler: nil)
        return true
    }

    /// Reveals a downloaded file in macOS Finder.
    public static func revealInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
#endif
