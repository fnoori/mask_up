import SwiftUI
import CoreLocation

struct NewDataSheet: View {
    @EnvironmentObject var isLoading: IsLoading
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext

    @State var chosenReminderType = 0
    @State var autoLocate = false

    @State var reminderModel = MaskReminderModel()
    @State var label: String = ""
    @State var daysOfWeek: [Int] = []
    @State var time: Date = Date()
    @State var radius: Int = 0
    @State var address: String = ""
    @State var lat: Double = 0.0
    @State var long: Double = 0.0

    let newDataSheetService = NewDataSheetService()
    var isEditing: Bool = false

    init(label: String?, daysOfWeek: [Int]?,
         time: Date?, radius: Int?, address: String?,
         lat: Double?, long: Double?) {

        self._label = label != nil ? State.init(initialValue: label!) : State.init(initialValue: "")
        self._daysOfWeek = daysOfWeek != nil ? State.init(initialValue: daysOfWeek!) : State.init(initialValue: [])
        self._time = time != nil ? State.init(initialValue: time!) : State.init(initialValue: Date())
        self._radius = radius != nil ? State.init(initialValue: radius!) : State.init(initialValue: 0)
        self._address = address != nil ? State.init(initialValue: address!) : State.init(initialValue: "")
        self._lat = lat != nil ? State.init(initialValue: lat!) : State.init(initialValue: 0.0)
        self._long = long != nil ? State.init(initialValue: long!) : State.init(initialValue: 0.0)

        self.isEditing = true
    }

    init() {
        self.isEditing = false
    }

    var body: some View {
        LoadingView(isShowing: .constant(self.isLoading.isLoading)) {
            NavigationView {
                Form {
                    Section {
                        ReminderTypePicker(chosenReminderType: self.$chosenReminderType)
                    }.pickerStyle(SegmentedPickerStyle())

                    TextField("Label", text: self.$label)

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
                                latitude: self.$lat,
                                longitude: self.$long
                            )
                            .environmentObject(self.isLoading)
                        }

                        if self.autoLocate == false {
                            Section(header: Text(""), footer: Text("If you don't want to use your location to set the reminder's centre, you can manually enter your address here.")) {
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
        self.reminderModel.label = self.label
        self.reminderModel.daysOfWeek = self.daysOfWeek
        self.reminderModel.time = self.time
        self.reminderModel.radius = Int16(self.radius)
        self.reminderModel.latitude = self.lat
        self.reminderModel.longitude = self.long
        self.reminderModel.address = self.address

        self.newDataSheetService.createNewReminder(reminder: self.reminderModel, isEditing: self.isEditing)
    }

    func canPressDone() -> Bool {
        self.chosenReminderType == 0
        || self.chosenReminderType == 1 && (self.lat != 0.0 && self.long != 0.0)
    }
}

