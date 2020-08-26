import SwiftUI

struct EditDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
  
    @State var maskReminder: MaskReminder
    @State var selectedDays: [Int]
    
    @State var timeIs: Date = Date()
    
    init(maskReminder: MaskReminder) {
        self._maskReminder = State.init(initialValue: maskReminder)
        self._selectedDays = State.init(initialValue: maskReminder.daysOfWeek)
    }
    
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
                        selection: $maskReminder.time ?? Date(),
                        displayedComponents: .hourAndMinute,
                        label: { Text("Reminder Time") }
                    )
                    TextField("Label", text: $maskReminder.label)
                }
                
                Section(header: Text("Repeat Days")) {
                    MultipleSelectionList(selections: $selectedDays)
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

// MARK: Operator Overloads

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
