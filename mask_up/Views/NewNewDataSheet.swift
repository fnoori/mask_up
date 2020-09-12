import SwiftUI
import CoreLocation

struct NewNewDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var chosenReminderType = 0
    @State var autoLocate = false

    @State var reminderModel = MaskReminderModel()
    @State var daysOfWeek: [Int] = []

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ReminderTypePicker(chosenReminderType: $chosenReminderType)
                }.pickerStyle(SegmentedPickerStyle())

                TextField("Label", text: $reminderModel.label)

                if self.chosenReminderType == 0 {
                    Section(header: Text("General")) {
                        ReminderTimePicker(time: $reminderModel.time)
                    }

                    Section(header: Text("some")) {
                        DaysOfWeekPicker(daysOfWeek: $daysOfWeek)
                    }
                } else {
                    Section(header: Text("Radius Limit"), footer: Text("How far do you want to walk away from the specified location before you receive a notification.")) {
                        Stepper("Metres \(self.reminderModel.radius)", value: $reminderModel.radius, in: 0...50, step: 5)
                    }

                    Section(header: Text(""), footer: Text("Uses your current location to set the location reminder's centre.")) {
                        AutoLocate(autoLocate: $autoLocate, latitude: $reminderModel.latitude, longitude: $reminderModel.longitude)
                    }

                    if self.autoLocate == false {
                        Section(header: Text(""), footer: Text("Manually input your address.")) {
                            ManualAddressEntry(address: $reminderModel.address, latitude: $reminderModel.latitude, longitude: $reminderModel.longitude)
                        }
                    }
                }
            }
            .keyboardResponsive()
            .navigationBarTitle("New Reminder", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) { Text("Cancel") },
                trailing: Button(action: {
                    print("saved")
                }) {
                    Text("Done")
                }.disabled(!self.canPressDone())
            )
        }
    }

    func canPressDone() -> Bool {
        self.chosenReminderType == 0
        || self.chosenReminderType == 1 && (self.reminderModel.latitude != 0.0 && self.reminderModel.longitude != 0.0)
    }
}

