import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: MaskReminder.entity(), sortDescriptors: [])
    
    var maskReminders: FetchedResults<MaskReminder>
    
    @State var showNewEntryModal: Bool = false
    @State var isEditMode: EditMode = .inactive
    @State var selectedMaskReminder: MaskReminder?
    
    func timeFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            do {
                self.managedObjectContext.delete(self.maskReminders[index])
                try self.managedObjectContext.save()
            } catch {
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
                                        self.showNewEntryModal = true
                                    }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }        
            }
            .navigationBarTitle("Mask Up")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: {
                    self.showNewEntryModal = true
                }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $showNewEntryModal) {
                    if self.selectedMaskReminder != nil {
                        EditDataSheet(maskReminder: self.selectedMaskReminder!)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                    } else {
                        NewDataSheet().environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
            )
            .environment(\.editMode, self.$isEditMode)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
