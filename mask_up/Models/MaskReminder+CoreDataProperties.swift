//
//  MaskReminder+CoreDataProperties.swift
//  mask_up
//
//  Created by Farzam Noori on 2020-09-07.
//  Copyright © 2020 Farzam Noori. All rights reserved.
//
//

import Foundation
import CoreData


extension MaskReminder: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaskReminder> {
        return NSFetchRequest<MaskReminder>(entityName: "MaskReminder")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var label: String
    @NSManaged public var isActive: Bool
    @NSManaged public var time: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var daysOfWeek: [Int]
    @NSManaged public var address: String

}
