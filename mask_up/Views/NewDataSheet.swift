import SwiftUI

struct NewDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var label: String = ""
    @State private var time: Date = Date()
    @State private var daysOfWeek: [Int] = []
    @State private var isActive: Bool = false
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return min...max
    }
    
    var body: some View {
        NavigationView {
            Form {
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
                    newReminder.daysOfWeek = self.daysOfWeek
                    
                    do {
                        try self.managedObjectContext.save()
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
}

struct NewData_Previews: PreviewProvider {
    static var previews: some View {
        NewDataSheet()
    }
}
