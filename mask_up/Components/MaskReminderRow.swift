import SwiftUI

struct MaskReminderRow: View {
    @ObservedObject var maskReminder: MaskReminder
    
    func timeFromDate(date: Date?) -> String {
        if let dateToConvert = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from: dateToConvert)
        } else {
            return ""
        }
    }
    
    func displayDaysOfWeek(daysOfWeek: [Int]) -> String {
        var processedDaysOfWeek = ""
        
        if daysOfWeek.count == 7 {
            processedDaysOfWeek = "Everyday"
        } else {
            for dayOfWeek in daysOfWeek {
                processedDaysOfWeek += "\(Calendar.current.shortWeekdaySymbols[dayOfWeek])  "
            }
        }
        
        return processedDaysOfWeek
    }
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    if self.maskReminder.latitude > 0.0 {
                        Image(systemName: "location.fill")
                    } else {
                        Image(systemName: "location")
                    }
                    Text(self.timeFromDate(date: self.maskReminder.time))
                        .font(.title)
                    Spacer()
                    Text(self.maskReminder.label)
                }
                HStack {
                    Text(self.displayDaysOfWeek(daysOfWeek: self.maskReminder.daysOfWeek))
                        .font(.subheadline)
                    Spacer()
                }
            }
        }.frame(height: 60)
    }
}
