import Foundation
import CoreData


extension MaskReminder: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaskReminder> {
        return NSFetchRequest<MaskReminder>(entityName: "MaskReminder")
    }

    @NSManaged public var label: String
    @NSManaged public var isActive: Bool
    @NSManaged public var time: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var daysOfWeek: [Int]

}
