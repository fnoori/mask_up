import SwiftUI
import CoreLocation
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var isLoading: IsLoading
    @EnvironmentObject var locationModel: LocationModel
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: MaskReminder.entity(), sortDescriptors: [])

    var maskReminders: FetchedResults<MaskReminder>
    
    @State var showNewEntryModal: Bool = false
    @State var showEditEntryModal: Bool = false
    @State var isEditMode: EditMode = .inactive
    @State var selectedMaskReminder: MaskReminder?
    
    let coreDataUtility = CoreDataUtility()
    
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
                    EditDataSheet()
                        .environment(\.managedObjectContext, self.managedObjectContext)
                        .environmentObject(self.isLoading)
                        .environmentObject(self.locationModel)
                }
            )
            .sheet(isPresented: $showEditEntryModal) {
                if self.selectedMaskReminder != nil {
//                    EditDataSheet(maskReminder: self.selectedMaskReminder!).environment(\.managedObjectContext, self.managedObjectContext)
                    EditDataSheet(
                        label: self.selectedMaskReminder!.label,
                        daysOfWeek: self.selectedMaskReminder!.daysOfWeek,
                        time: self.selectedMaskReminder!.time,
                        radius: Int(self.selectedMaskReminder!.radius),
                        address: self.selectedMaskReminder!.address,
                        lat: self.selectedMaskReminder!.latitude,
                        long: self.selectedMaskReminder!.longitude
                    )
                    .environment(\.managedObjectContext, self.managedObjectContext)
                    .environmentObject(self.isLoading)
                    .environmentObject(self.locationModel)
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
