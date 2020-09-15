import Foundation
import CoreData
import UIKit

class NewDataSheetService {
    private let appDelegate: AppDelegate
    private let managedContext: NSManagedObjectContext

    private let coreDataUtility: CoreDataUtility
    private let notificationService: NotificationService

    init() {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedContext = appDelegate.persistentContainer.viewContext

        self.coreDataUtility = CoreDataUtility()
        self.notificationService = NotificationService()
    }

    public func createNewReminder(reminder: MaskReminderModel) {
        let newReminder = MaskReminder(context: self.managedContext)

        newReminder.id = UUID()
        newReminder.label = reminder.label

        newReminder.latitude = reminder.latitude
        newReminder.longitude = reminder.longitude
        newReminder.radius = reminder.radius

        newReminder.address = reminder.address
        newReminder.time = reminder.time

        newReminder.isActive = true
        newReminder.daysOfWeek = reminder.daysOfWeek

        do {
            try self.managedContext.save()

            self.notificationService.buildNotification(newReminder: newReminder)
        } catch {
            print("Tried to save but an error occurred\n\(error.localizedDescription)")
        }
    }
}

