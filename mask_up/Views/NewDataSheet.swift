import SwiftUI

struct NewDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var label: String = ""
    @State private var time: Date = Date()
    @State private var daysOfWeek: [Int] = []
    @State private var isActive: Bool = false
    
    private var newReminderType = ["Simple", "Location Based"]
    @State private var chosenReminderType = 0
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return min...max
    }
    
    
//    @State var mapChoioce = 0
//    var settings = ["Map", "Transit", "Satellite"]
//    Picker("Options", selection: $mapChoioce) {
//        ForEach(0 ..< settings.count) { index in
//            Text(self.settings[index])
//                .tag(index)
//        }
//
//    }.pickerStyle(SegmentedPickerStyle())
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Options", selection: $chosenReminderType) {
                        ForEach(0 ..< newReminderType.count) { index in
                            Text(self.newReminderType[index]).tag(index)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                
                if self.chosenReminderType == 0 {
                    // TODO: plain notification
                    Section(header: Text("General")) {
                        DatePicker(
                            selection: $time,
                            displayedComponents: .hourAndMinute,
                            label: { Text("Reminder Time") }
                        )
                        TextField("Label", text: $label)
                    }
                    
                    Section(header: Text("Repeat Days")) {
                        MultipleSelectionList(selections: $daysOfWeek)
                    }
                } else {
                    // TODO: location based
                }
                
               
            }
            .navigationBarTitle("New Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    let newReminder = MaskReminder(context: self.managedObjectContext)
                    
                    newReminder.id = UUID()
                    newReminder.label = self.label
                    newReminder.isActive = true
                    newReminder.time = self.time
                    newReminder.daysOfWeek = self.daysOfWeek.indices.map { $0 + 1 }
                    
                    do {
                        try self.managedObjectContext.save()
                        
                        for weekday in self.daysOfWeek {
                            let content = UNMutableNotificationContent()
                            content.title = "Don't forget your mask"
                            content.subtitle = self.label
                            content.sound = UNNotificationSound.default

                            var dateComponents = DateComponents()
                            dateComponents.calendar = Calendar.current
                            
                            dateComponents.weekday = self.parseWeekday(weekday: weekday)
                            dateComponents.hour = self.parseHour(date: self.time)
                            dateComponents.minute = self.parseMinute(date: self.time)

                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                            let request = UNNotificationRequest(identifier: newReminder.id!.uuidString, content: content, trigger: trigger)

                            let notificationCenter = UNUserNotificationCenter.current()
                            notificationCenter.add(request) { (error) in
                               if error != nil {
                                  // Handle any errors.
                               }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
    }
    
    func parseWeekday(weekday: Int) -> Int {
        return weekday + 2
    }
    
    func parseHour(date: Date) -> Int {
        return Calendar.current.component(.hour, from: date)
    }
    
    func parseMinute(date: Date) -> Int {
        return Calendar.current.component(.minute, from: date)
    }
}

struct NewData_Previews: PreviewProvider {
    static var previews: some View {
        NewDataSheet()
    }
}
