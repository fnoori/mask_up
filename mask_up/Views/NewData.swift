import SwiftUI

struct NewData: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var something: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Hi", text: $something)
                }
            }
            .navigationBarTitle("New Reminder")
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                },
                trailing: Button(action: {
                    print("New Entry !")
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
    }
}

struct NewData_Previews: PreviewProvider {
    static var previews: some View {
        NewData()
    }
}
