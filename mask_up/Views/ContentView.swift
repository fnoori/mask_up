import SwiftUI
import CoreLocation
import UserNotifications

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: MaskReminder.entity(), sortDescriptors: [])

    var maskReminders: FetchedResults<MaskReminder>
    
    @State var showNewEntryModal: Bool = false
    @State var showEditEntryModal: Bool = false
    @State var isEditMode: EditMode = .inactive
    @State var selectedMaskReminder: MaskReminder?
    
    let coreDataUtility = CoreDataUtility()
    
    let locationManager = CLLocationManager()
    
    func timeFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            let maskReminder = self.maskReminders[index]
            coreDataUtility.deleteData(id: maskReminder.id!)
        }
    }
    
    init() {
        UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("\n\nAll set !\n\n")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("need location to use location based notification")
            break
        default:
            print("need location for location based notificaion")
        }
        
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("\n\n")
                print(request)
                print("\n\n")
            }
        })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if self.maskReminders.count > 0 {
                        ForEach(maskReminders) { maskReminder in
                            MaskReminderRow(maskReminder: maskReminder)
                                .onTapGesture {
                                    if self.isEditMode == .active {
                                        self.selectedMaskReminder = maskReminder
                                        self.showEditEntryModal.toggle()
                                    }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }        
            }
            .navigationBarTitle("Mask Up", displayMode: .inline)
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    self.showNewEntryModal.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showNewEntryModal) {
                    NewDataSheet().environment(\.managedObjectContext, self.managedObjectContext)
                }
            )
            .sheet(isPresented: $showEditEntryModal) {
                if self.selectedMaskReminder != nil {
                    EditDataSheet(maskReminder: self.selectedMaskReminder!).environment(\.managedObjectContext, self.managedObjectContext)
                }
            }
            .environment(\.editMode, self.$isEditMode)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
