import SwiftUI

struct ContentView: View {
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
            do {
                let maskReminder = self.maskReminders[index]
                
                self.managedObjectContext.delete(self.maskReminders[index])
                coreDataUtility.deleteData(id: maskReminder.id)
                
                try self.managedObjectContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    init() {
        UNUserNotificationCenter.current()
        .requestAuthorization(options:
        [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set !")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
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
                EditDataSheet(maskReminder: self.selectedMaskReminder!).environment(\.managedObjectContext, self.managedObjectContext)
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
