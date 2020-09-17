import Foundation
import CoreData
import UIKit

class CoreDataUtility {

    func updateData(updatedReminder: MaskReminder) throws {
//        var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LoginData")
//        fetchRequest.predicate = NSPredicate(format: "userName = %@", userName)
//
//        if let fetchResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
//            if fetchResults.count != 0{
//
//                var managedObject = fetchResults[0]
//                managedObject.setValue(accessToken, forKey: "accessToken")
//
//                context.save(nil)
//            }
//        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MaskReminder")
        fetchRequest.predicate = NSPredicate(format: "id = %@", updatedReminder.id! as CVarArg)

        do {
            if let fetchResult = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
//                let maskReminderObject = fetchResult[0] as! MaskReminder

                let objectToUpdate = fetchResult[0]

                managedContext.delete(objectToUpdate)

                objectToUpdate.setValue(updatedReminder.id, forKey: "id")
                objectToUpdate.setValue(updatedReminder.latitude, forKey: "latitude")
                objectToUpdate.setValue(updatedReminder.longitude, forKey: "longitude")
                objectToUpdate.setValue(updatedReminder.label, forKey: "label")
                objectToUpdate.setValue(updatedReminder.isActive, forKey: "isActive")
                objectToUpdate.setValue(updatedReminder.time, forKey: "time")
                objectToUpdate.setValue(updatedReminder.daysOfWeek, forKey: "daysOfWeek")
                objectToUpdate.setValue(updatedReminder.address, forKey: "address")
                objectToUpdate.setValue(updatedReminder.radius, forKey: "radius")

//                maskReminderObject.latitude = updatedReminder.latitude
//                maskReminderObject.longitude = updatedReminder.longitude
//                maskReminderObject.label = updatedReminder.label
//                maskReminderObject.isActive = updatedReminder.isActive
//                maskReminderObject.time = updatedReminder.time
//                maskReminderObject.daysOfWeek = updatedReminder.daysOfWeek
//                maskReminderObject.address = updatedReminder.address
//                maskReminderObject.radius = updatedReminder.radius

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
