import Foundation
import UserNotifications

public final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationsManager()

    /// Requests local user notification authorization from macOS.
    public func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }

    /// Dispatches a local user notification alerting that an ISO download has completed.
    public func postDownloadCompleted(fileName: String, fileURL: URL) {
        let content = UNMutableNotificationContent()
        content.title = "Windows ISO Download Complete"
        content.body = "\(fileName) is ready in your destination folder."
        content.sound = .default
        content.userInfo = ["fileURL": fileURL.path]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { _ in }
    }

    /// Displays incoming notifications as foreground banners with sound.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
