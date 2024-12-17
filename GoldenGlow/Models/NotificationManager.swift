import Foundation
import NotificationCenter

class NotificationManager {

    static let shared = NotificationManager()
    let notificationSentences: [String] = [
        "It's Golden hour!"
    ]

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { granted, error in
            if granted {
                print("Permission granted for notifications")
            } else {
                print(
                    "Permission denied: \(String(describing: error?.localizedDescription))"
                )
            }
        }
    }

    func scheduleDailyNotifications() {
        let times = [
            (hour: 11, minute: 56)
        ]

        for (index, time) in times.enumerated() {
            let sentence =
                notificationSentences.randomElement() ?? "Stay positive!"
            scheduleNotification(
                atHour: time.hour, minute: time.minute, title: "Daily Reminder",
                body: sentence, identifier: "notification-\(index)")
        }
    }

    private func scheduleNotification(
        atHour hour: Int, minute: Int, title: String, body: String,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(
                    "Error scheduling notification: \(error.localizedDescription)"
                )
            }
        }
    }
}
