import SwiftUI

struct DaysOfWeekPicker: View {
    @Binding var daysOfWeek: [Int]

    var body: some View {
        MultipleSelectionList(selections: $daysOfWeek)
    }
}
