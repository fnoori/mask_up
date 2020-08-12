import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showNewEntryModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Text("9:00")
                }
            }
            .navigationBarTitle("Mask Up")
            .navigationBarItems(
                leading: Button(action: {
                    print("Edit !")
                }) {
                    Text("Edit")
                },
                trailing: Button(action: {
                    self.showNewEntryModal = true
                }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $showNewEntryModal) {
//                    NewDataSheet().environment(\.managedObjectContext, self.managedObjectContext)
                    NewDataSheet().environment(\.managedObjectContext, self.managedObjectContext)
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
