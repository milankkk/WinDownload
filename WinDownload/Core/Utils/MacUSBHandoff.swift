import Foundation
#if canImport(AppKit)
import AppKit

public struct MacUSBHandoff {
    public static var isMacUSBInstalled: Bool {
        if let _ = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.kruszoneq.macusb") {
            return true
        }
        let directAppURL = URL(fileURLWithPath: "/Applications/macUSB.app")
        return FileManager.default.fileExists(atPath: directAppURL.path)
    }

    public static func openInMacUSB(isoFileURL: URL) -> Bool {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.kruszoneq.macusb") {
            let config = NSWorkspace.OpenConfiguration()
            config.promptsUserIfNeeded = true
            NSWorkspace.shared.open([isoFileURL], withApplicationAt: appURL, configuration: config, completionHandler: nil)
            return true
        }

        let directAppURL = URL(fileURLWithPath: "/Applications/macUSB.app")
        if FileManager.default.fileExists(atPath: directAppURL.path) {
            let config = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.open([isoFileURL], withApplicationAt: directAppURL, configuration: config, completionHandler: nil)
            return true
        }

        return false
    }

    public static func revealInFinder(url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
#endif
