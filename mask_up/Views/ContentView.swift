import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var showNewEntryModal: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TodayView()
            }
            .navigationBarTitle("Home")
            .navigationBarItems(trailing:
                Button(action: {
                    self.showNewEntryModal = true
                }) {
                    Image(systemName: "plus")
                }.sheet(isPresented: $showNewEntryModal) {
                    NewData().environment(\.managedObjectContext, self.managedObjectContext)
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
