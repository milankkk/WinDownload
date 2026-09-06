import Foundation
import UserNotifications

public final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationsManager()

    public func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }

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

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
