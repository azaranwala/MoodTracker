import Foundation
import UserNotifications

/// Manages local notifications for mood reminders
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    /// Request notification authorization
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        do {
            let status = try await center.requestAuthorization(options: options)
            return status
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    /// Schedule mood reminder notifications
    func scheduleReminders(time: Date, frequency: SettingsView.ReminderFrequency) {
        let center = UNUserNotificationCenter.current()
        
        // Remove existing notifications
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Check Your Mood"
        content.body = "How are you feeling today?"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        switch frequency {
        case .daily:
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "dailyReminder",
                                               content: content,
                                               trigger: trigger)
            center.add(request)
            
        case .twiceDaily:
            // Schedule morning reminder
            var morningComponents = components
            morningComponents.hour = 10
            let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningComponents, repeats: true)
            let morningRequest = UNNotificationRequest(identifier: "morningReminder",
                                                     content: content,
                                                     trigger: morningTrigger)
            center.add(morningRequest)
            
            // Schedule evening reminder
            var eveningComponents = components
            eveningComponents.hour = 18
            let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComponents, repeats: true)
            let eveningRequest = UNNotificationRequest(identifier: "eveningReminder",
                                                     content: content,
                                                     trigger: eveningTrigger)
            center.add(eveningRequest)
            
        case .custom:
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "customReminder",
                                               content: content,
                                               trigger: trigger)
            center.add(request)
        }
    }
    
    /// Remove all scheduled notifications
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Get notification settings
    func getNotificationSettings() async -> UNNotificationSettings {
        return await UNUserNotificationCenter.current().notificationSettings()
    }
}

/// Notification handling extension
extension NotificationManager {
    /// Handle notification response
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        // Open the app to the home tab when notification is tapped
        if response.notification.request.identifier.hasPrefix("reminder") {
            // TODO: Implement app state restoration to show home tab
        }
    }
}
