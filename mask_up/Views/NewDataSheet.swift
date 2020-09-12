import SwiftUI
import CoreLocation

struct NewDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var maskReminderModel = MaskReminderModel()
    
    @State private var label: String = ""
    @State private var time: Date = Date()
    @State private var daysOfWeek: [Int] = []
    @State private var isActive: Bool = false
    
    @State private var address: String = ""
    
    @State private var autoLocate: Bool = false
    @State private var lat: Double = 0.0
    @State private var long: Double = 0.0
    @State private var radius: Int = 0
    
    let geoCoder = CLGeocoder()
    
    private var newReminderType = ["Simple", "Location Based"]
    @State private var chosenReminderType = 0
    
    var dateClosedRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return min...max
    }
    
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
                
                TextField("Label", text: $maskReminderModel.label)
                
                if self.chosenReminderType == 1 {
                    Section(header: Text("Radius Limit"), footer: Text("How far do you want to walk away from the specified location before you receive a notification.")) {
                        Stepper("Metres \(self.maskReminderModel.radius)", value: $maskReminderModel.radius, in: 0...50, step: 5)
                    }
                }
                
                if self.chosenReminderType == 0 {
                    Section(header: Text("General")) {
                        DatePicker(
                            selection: $maskReminderModel.time,
                            displayedComponents: .hourAndMinute,
                            label: { Text("Reminder Time") }
                        )
                    }
                    
                    Section(header: Text("Repeat Days")) {
                        MultipleSelectionList(selections: $daysOfWeek)
                    }
                } else {
                    Section(header: Text(""), footer: Text("Uses your current location to set the location reminder's centre.")) {
                        Toggle(isOn: $autoLocate) {
                            Text("Locate Me Automatically")
                        }.onReceive([self.autoLocate].publisher.first()) { (value) in
                            if value == true {
                                self.getCurrentLocation()
                            } else {
                                self.maskReminderModel.latitude = 0.0
                                self.maskReminderModel.longitude = 0.0
                            }
                        }
                    }
                    
                    if !self.autoLocate {
                        Section(header: Text(""), footer: Text("Manually input your address.")) {
                            TextField("Address", text: $maskReminderModel.address, onCommit: {
                                let geoCoder = CLGeocoder()
                                geoCoder.geocodeAddressString(self.maskReminderModel.address) { (placemarks, error) in
                                    guard let placemarks = placemarks, let location = placemarks.first?.location else { return }
                                    
                                    self.maskReminderModel.latitude = location.coordinate.latitude
                                    self.maskReminderModel.longitude = location.coordinate.longitude
                                }
                            }).keyboardType(.webSearch)
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
                    let newReminder = MaskReminder(context: self.managedObjectContext)
                    
                    newReminder.id = UUID()
                    newReminder.label = self.maskReminderModel.label
                    newReminder.isActive = true
                    newReminder.time = self.maskReminderModel.time
                    newReminder.daysOfWeek = self.daysOfWeek
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Don't forget your mask"
                    content.subtitle = self.label
                    content.sound = UNNotificationSound.default
                    
                    if self.chosenReminderType == 0 {
                        do {
                            try self.managedObjectContext.save()
                            
                            for weekday in self.daysOfWeek {
                                var dateComponents = DateComponents()
                                dateComponents.calendar = Calendar.current
                                
                                dateComponents.weekday = self.parseWeekday(weekday: weekday)
                                dateComponents.hour = self.parseHour(date: newReminder.time!)
                                dateComponents.minute = self.parseMinute(date: newReminder.time!)
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                                
                                let request = UNNotificationRequest(identifier: "\(weekday)_\(newReminder.id!.uuidString)", content: content, trigger: trigger)
                                
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
                    } else {
                        if self.autoLocate {
                            if CLLocationManager.locationServicesEnabled() {
                                let centre = CLLocationCoordinate2D(latitude: self.maskReminderModel.latitude, longitude: self.maskReminderModel.longitude)
                                let region = CLCircularRegion(center: centre, radius: CLLocationDistance(self.radius), identifier: newReminder.id!.uuidString)
                                
                                region.notifyOnExit = true
                                region.notifyOnEntry = false
                                
                                let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                                let request = UNNotificationRequest(identifier: newReminder.id!.uuidString, content: content, trigger: trigger)
                                
                                let notificationCentre = UNUserNotificationCenter.current()
                                
                                notificationCentre.add(request) { (error) in
                                    if error != nil {
                                        // Handle error
                                    }
                                }
                            } else {
                                print("Please enable location permission")
                            }
                        } else {
                            let center = CLLocationCoordinate2D(latitude: self.maskReminderModel.latitude, longitude: self.maskReminderModel.longitude)
                            let region = CLCircularRegion(center: center, radius: CLLocationDistance(self.radius), identifier: newReminder.id!.uuidString)
                            region.notifyOnExit = true
                            region.notifyOnEntry = false
                            let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
                            
                            let request = UNNotificationRequest(identifier: newReminder.id!.uuidString, content: content, trigger: trigger)
                            
                            let notificationCenter = UNUserNotificationCenter.current()
                            notificationCenter.add(request) { (error) in
                                if error != nil {
                                    // Handle any errors.
                                }
                            }
                        }
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }.disabled(!self.canPressDone())
            )
        }
    }
    
    func canPressDone() -> Bool {
        return
            self.chosenReminderType == 1 && (self.autoLocate == false && (self.maskReminderModel.latitude != 0.0 && self.maskReminderModel.longitude != 0.0))
            || self.chosenReminderType == 0
            || self.chosenReminderType == 1 && (self.autoLocate == true && (self.maskReminderModel.latitude != 0.0 && self.maskReminderModel.longitude != 0.0))
    }
    
    func getCurrentLocation() {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        DispatchQueue.main.async {
            self.maskReminderModel.latitude = locationManager.location!.coordinate.latitude
            self.maskReminderModel.longitude = locationManager.location!.coordinate.longitude
            
            locationManager.stopUpdatingLocation()
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
