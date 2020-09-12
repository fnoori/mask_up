import Foundation
import SwiftUI

class MaskReminderModel {
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var label: String = ""
    var isActive: Bool = false
    var time: Date = Date()
    var id: UUID = UUID()
    var daysOfWeek = [Int]()
    var address: String = ""
    var radius: Int16 = 0
}
