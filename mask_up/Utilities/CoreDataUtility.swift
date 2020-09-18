import Foundation
import CoreData
import UIKit

class CoreDataUtility {

    func updateData(updatedReminder: MaskReminder) throws {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MaskReminder")
        fetchRequest.predicate = NSPredicate(format: "id = %@", updatedReminder.id! as CVarArg)

        do {
            if let fetchResult = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {

                let fetchedObject = fetchResult[0]

                fetchedObject.setValue(updatedReminder.latitude, forKey: "latitude")
                fetchedObject.setValue(updatedReminder.longitude, forKey: "longitude")
                fetchedObject.setValue(updatedReminder.label, forKey: "label")
                fetchedObject.setValue(updatedReminder.isActive, forKey: "isActive")
                fetchedObject.setValue(updatedReminder.time, forKey: "time")
                fetchedObject.setValue(updatedReminder.daysOfWeek, forKey: "daysOfWeek")
                fetchedObject.setValue(updatedReminder.address, forKey: "address")
                fetchedObject.setValue(updatedReminder.radius, forKey: "radius")

                try managedContext.save()
            }
        } catch {
            print("could not update\n\(error.localizedDescription)")
        }
    }

    func retrieveAllData() -> [NSManagedObject]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MaskReminder")
        
        do {
            return try managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func retrieveData(id: UUID) -> [NSManagedObject]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MaskReminder")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
        
        do {
            return try managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    func deleteData(id: UUID) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MaskReminder")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let maskReminder = try managedContext.fetch(fetchRequest)
            let maskReminderObject = maskReminder[0] as! MaskReminder
            
            let reminderToDelete = maskReminder[0] as! NSManagedObject
            managedContext.delete(reminderToDelete)

            var notificationToDeleteIds: [String] = []
            if maskReminderObject.daysOfWeek.count > 0 {
                for weekday in maskReminderObject.daysOfWeek {
                    notificationToDeleteIds.append("\(weekday)_\(maskReminderObject.id!.uuidString)")
                }
            } else {
                notificationToDeleteIds.append(maskReminderObject.id!.uuidString)
            }

            UNUserNotificationCenter
                .current()
                .removePendingNotificationRequests(
                    withIdentifiers: notificationToDeleteIds
                )
            
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
