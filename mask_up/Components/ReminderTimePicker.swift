import SwiftUI

struct ReminderTimePicker: View {
    @Binding var time: Date

    var body: some View {
        DatePicker(
                selection: $time,
                displayedComponents: .hourAndMinute,
                label: { Text("Reminder Time") }
        )
    }
}