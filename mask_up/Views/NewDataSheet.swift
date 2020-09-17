import SwiftUI
import CoreLocation

struct NewDataSheet: View {
    @EnvironmentObject var isLoading: IsLoading
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var chosenReminderType = 0
    @State var autoLocate = false

    @State var reminderModel = MaskReminderModel()
    @State var daysOfWeek: [Int] = []
    @State var time: Date = Date()
    @State var radius: Int = 0
    @State var address: String = ""
    @State var lat: Double = 0.0
    @State var long: Double = 0.0

    let newDataSheetService = NewDataSheetService()

    var body: some View {
        LoadingView(isShowing: .constant(self.isLoading.isLoading)) {
            NavigationView {
                Form {
                    Section {
                        ReminderTypePicker(chosenReminderType: self.$chosenReminderType)
                    }.pickerStyle(SegmentedPickerStyle())

                    TextField("Label", text: self.$reminderModel.label)

                    if self.chosenReminderType == 0 {
                        Section(header: Text("General")) {
                            ReminderTimePicker(time: self.$time)
                        }

                        Section(header: Text("some")) {
                            DaysOfWeekPicker(daysOfWeek: self.$daysOfWeek)
                        }
                    } else {
                        Section(
                            header: Text("Radius Limit"),
                            footer: Text("How far do you want to walk away from the specified location before you receive a notification.")
                        ) {
                            Stepper(
                                "Metres \(self.radius)",
                                value: self.$radius,
                                in: 0...50, step: 5
                            )
                        }

                        Section(
                            header: Text(""),
                            footer: Text("Uses your current location to set the location reminder's centre.")
                        ) {
                            AutoLocate(
                                autoLocate: self.$autoLocate,
                                latitude: self.$reminderModel.latitude,
                                longitude: self.$reminderModel.longitude
                            )
                            .environmentObject(self.isLoading)
                        }

                        if self.autoLocate == false {
                            Section(header: Text(""), footer: Text("Manually input your address.")) {
                                ManualAddressEntry(
                                    address: self.$address,
                                    latitude: self.$lat,
                                    longitude: self.$long
                                )
                            }
                        }
                    }
                }
                .keyboardResponsive()
                .navigationBarTitle("New Reminder", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                    },
                    trailing: Button(action: {
                        self.populateOtherModel()

                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }.disabled(!self.canPressDone())
                )
            }
        }
    }

    func populateOtherModel() {
        self.reminderModel.daysOfWeek = self.daysOfWeek
        self.reminderModel.time = self.time
        self.reminderModel.radius = Int16(self.radius)
        self.reminderModel.latitude = self.lat
        self.reminderModel.longitude = self.long
        self.reminderModel.address = self.address

        self.newDataSheetService.createNewReminder(reminder: self.reminderModel)
    }

    func canPressDone() -> Bool {
        self.chosenReminderType == 0
        || self.chosenReminderType == 1 && (self.lat != 0.0 && self.long != 0.0)
    }
}

