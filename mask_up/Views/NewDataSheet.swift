import SwiftUI
import CoreLocation

struct NewDataSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var label: String = ""
    @State private var time: Date = Date()
    @State private var daysOfWeek: [Int] = []
    @State private var isActive: Bool = false
        
    @State private var street: String = "7020 4 St NW"
    @State private var unitNumber: String = ""
    @State private var city: String = "Calgary"
    @State private var provinceState: String = "AB"
    @State private var country: String = "Canada"
    @State private var postCode: String = "T2K 1C4"
    
    @State private var autoLocate: Bool = false
    @State private var lat: Double = 0.0
    @State private var long: Double = 0.0
    @State private var radius: Int = 100
    
    private var newReminderType = ["Simple", "Location Based"]
    @State private var chosenReminderType = 0
    
    let myLat = 51.043000
    let myLong = -114.039310
    
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
                
                TextField("Label", text: $label)
                
                if self.chosenReminderType == 0 {
                    Section(header: Text("General")) {
                        DatePicker(
                            selection: $time,
                            displayedComponents: .hourAndMinute,
                            label: { Text("Reminder Time") }
                        )
                    }
                    
                    Section(header: Text("Repeat Days")) {
                        MultipleSelectionList(selections: $daysOfWeek)
                    }
                } else {
                    Toggle(isOn: $autoLocate) {
                        Text("Locate Me Automatically")
                    }
                    
                    if !self.autoLocate {
                        Section(header: Text("Manual Address Input")) {
                            TextField("Street", text: $street)
                            TextField("Unit Number", text: $unitNumber)
                        }
                        
                        Section {
                            TextField("City", text: $city)
                            TextField("Provice/State", text: $provinceState)
                            TextField("Country", text: $country)
                        }
                        
                        Section {
                            TextField("Postal Code", text: $postCode)
                        }
                    } else {
                        Text("LOCATE ME !")
                    }
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
                    } else {
                        if self.autoLocate {
                            if CLLocationManager.locationServicesEnabled() {
                                let locationManager = CLLocationManager()
                                locationManager.distanceFilter = kCLDistanceFilterNone
                                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                                
                                locationManager.startUpdatingLocation()
                                
                                self.lat = locationManager.location!.coordinate.latitude
                                self.long = locationManager.location!.coordinate.longitude
                                
                                let centre = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
                                let region = CLCircularRegion(center: centre, radius: CLLocationDistance(self.radius), identifier: self.label)
                                
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
                            var fullAddress = ""
                            if self.unitNumber != "" {
                                fullAddress += "\(self.unitNumber) - "
                            }
                            
                            fullAddress += "\(self.street), \(self.city) \(self.provinceState) \(self.country), \(self.postCode)"
                            
                            self.getCoordinates(fullAddress) { (location) in
                                print(location)
                            }
                            
//                            var geocoder = CLGeocoder()
                            
//                            DispatchQueue.main.async {
//                                geocoder.geocodeAddressString(fullAddress) {
//                                    placemarks, error in
//                                    let placemark = placemarks?.first
//                                    let lat = placemark?.location?.coordinate.latitude
//                                    let lon = placemark?.location?.coordinate.longitude
//                                    print("Lat: \(lat), Lon: \(lon)")
//                                }
//                            }
                            
//                            let center = CLLocationCoordinate2D(latitude: self.myLat, longitude: self.myLong)
//                            let region = CLCircularRegion(center: center, radius: 2000, identifier: "Headquarters")
//                            region.notifyOnExit = true
//                            region.notifyOnEntry = false
//                            let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
//
//                            let request = UNNotificationRequest(identifier: newReminder.id!.uuidString, content: content, trigger: trigger)
//
//                            let notificationCenter = UNUserNotificationCenter.current()
//                            notificationCenter.add(request) { (error) in
//                                if error != nil {
//                                    // Handle any errors.
//                                }
//                            }
                        }
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
    }
    
    func getCoordinates(_ address: String,completion:@escaping((CLLocationCoordinate2D) -> ())){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks, let location = placemarks.first?.location else { return }

            completion(location.coordinate)
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
