import Foundation
import SwiftUI

class NotificationService {
    public func buildNotification(newReminder: MaskReminder) {
        let content = UNMutableNotificationContent()

        content.title = "Don't forget your mask"
        content.subtitle = newReminder.label
        content.sound = UNNotificationSound.default

        if isLocationBased(reminder: newReminder) {
            self.createLocationBasedNotification(newReminder: newReminder, content: content)
        } else {
            self.createBasicNotification(newReminder: newReminder, content: content)
        }
    }

    private func isLocationBased(reminder: MaskReminder) -> Bool {
        reminder.longitude != 0.0 && reminder.latitude != 0.0
    }

    private func createBasicNotification(newReminder: MaskReminder, content: UNMutableNotificationContent) {
        for weekday in newReminder.daysOfWeek {
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current

            dateComponents.weekday = self.parseWeekday(weekday: weekday)
            dateComponents.hour = self.parseHour(date: newReminder.time!)
            dateComponents.minute = self.parseMinute(date: newReminder.time!)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                    identifier: "\(weekday)_\(newReminder.id!.uuidString)",
                    content: content,
                    trigger: trigger
            )

            let notificationCentre = UNUserNotificationCenter.current()
            notificationCentre.add(request) { (error) in
                if error != nil {
                    print("Could not save notification")
                }
            }
        }
    }

    private func createLocationBasedNotification(newReminder: MaskReminder, content: UNMutableNotificationContent) {

    }

    private func parseWeekday(weekday: Int) -> Int {
        weekday + 2
    }

    private func parseHour(date: Date) -> Int {
        Calendar.current.component(.hour, from: date)
    }

    private func parseMinute(date: Date) -> Int {
        Calendar.current.component(.minute, from: date)
    }
}