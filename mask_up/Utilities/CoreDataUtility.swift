import Foundation
import CoreData
import UIKit

class CoreDataUtility {
    
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
            
            let reminderToDelete = maskReminder[0] as! NSManagedObject
            managedContext.delete(reminderToDelete)
            
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}
