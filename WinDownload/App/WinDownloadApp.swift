import SwiftUI
#if canImport(WinDownloadCore)
@_exported import WinDownloadCore
#endif
#if canImport(AppKit)
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
}
#endif

@main
struct WinDownloadApp: App {
    #if canImport(AppKit)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    init() {
        #if canImport(AppKit)
        // Enforce single running instance
        if let bundleId = Bundle.main.bundleIdentifier {
            let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
            if runningApps.count > 1 {
                for app in runningApps where app.processIdentifier != ProcessInfo.processInfo.processIdentifier {
                    app.activate()
                }
                NSApplication.shared.terminate(nil)
            }
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        #if os(macOS)
        .windowToolbarStyle(.unifiedCompact(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .appInfo) {
                Divider()
                Button("Check for Updates...") {
                    // Update checking trigger
                }
            }
        }
        #endif
    }
}
