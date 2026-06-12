import Foundation
import UserNotifications

// Schedules local notifications for key dates. Local notifications work
// entirely on-device — no server or Apple push setup needed.
enum ReminderScheduler {
    /// Asks the user for notification permission the first time;
    /// afterwards just reports the current setting.
    static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        default:
            return false
        }
    }

    /// Reminds at 6 pm the evening before, or 7 am on the day if the
    /// evening before has already passed.
    static func schedule(for event: FamilyEvent) {
        cancel(for: event)
        guard event.reminderEnabled else { return }

        let calendar = Calendar.current
        var fireDate = calendar.date(byAdding: .day, value: -1, to: event.date)
            .flatMap { calendar.date(bySettingHour: 18, minute: 0, second: 0, of: $0) }
        if let date = fireDate, date <= .now {
            fireDate = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: event.date)
        }
        guard let fireDate, fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        content.title = event.title
        var parts: [String] = []
        if let childName = event.child?.name { parts.append(childName) }
        parts.append(event.date.formatted(date: .abbreviated, time: .omitted))
        if !event.notes.isEmpty { parts.append(event.notes) }
        content.body = parts.joined(separator: " · ")
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: event.reminderID, content: content, trigger: trigger)
        )
    }

    static func cancel(for event: FamilyEvent) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [event.reminderID])
    }
}
