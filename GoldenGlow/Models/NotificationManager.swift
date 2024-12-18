import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()
    let notificationSentences: [String] = [
        "It's Golden hour!"
    ]

    private func requestPermission() {
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
    
    // Schedule the notification for a specific date and with a custom sound
    private func scheduleNotification(atHour hour: Int, minute: Int) {
        var dateComponents = DateComponents()
        dateComponents.hour = 12
        dateComponents.minute = 12
        
        let content = UNMutableNotificationContent()
        // Sets up notification information
        content.title = "GoldenGlow"
        content.body = "It's golden hour"
        content.userInfo = ["deepLink": "throwalarm://alarm"] // Deep link for the minigame
        // Get component from Date in order to schedule for a specific time
        // Create the trigger based on date components

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a unique request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // Adds request to notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error while scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification successfully scheduled")
            }
        }
    }

    func sendNotification(atHour hour: Int, minute: Int){
        requestPermission()
        scheduleNotification(atHour: hour, minute: minute)
    }
    
}

