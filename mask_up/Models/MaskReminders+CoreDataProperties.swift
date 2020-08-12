//
//  MaskReminders+CoreDataProperties.swift
//  mask_up
//
//  Created by Farzam Noori on 2020-08-11.
//  Copyright © 2020 Farzam Noori. All rights reserved.
//
//

import Foundation
import CoreData


extension MaskReminders {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaskReminders> {
        return NSFetchRequest<MaskReminders>(entityName: "MaskReminders")
    }

    @NSManaged public var daysOfWeek: [Int]
    @NSManaged public var id: UUID
    @NSManaged public var isActive: Bool
    @NSManaged public var label: String
    @NSManaged public var time: Date

}
