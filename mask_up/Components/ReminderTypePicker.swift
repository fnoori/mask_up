import SwiftUI
import CoreLocation

struct ReminderTypePicker: View {
    var reminderType = ["Simple", "Location Based"]

    @Binding var chosenReminderType: Int

    var body: some View {
        Picker("Options", selection: $chosenReminderType) {
            ForEach(0 ..< self.reminderType.count) { index in
                Text(self.reminderType[index]).tag(index)
            }
        }
    }
}
