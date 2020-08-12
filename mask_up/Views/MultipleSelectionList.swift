import SwiftUI

struct MultipleSelectionList: View {
    @State var items: [String] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @Binding var selections: [Int]

    func getIndex(value: String) -> Int {
        return self.items.firstIndex(of: value)!
    }
    
    var body: some View {
        List {
            ForEach(self.items, id: \.self) { item in
                MultipleSelectionRow(title: item, isSelected: self.selections.contains(self.getIndex(value: item))) {
                    if self.selections.contains(self.getIndex(value: item)) {
                        self.selections.removeAll(where: { $0 == self.getIndex(value: item) })
                    }
                    else {
                        self.selections.append(self.items.firstIndex(of: item)!)
                    }
                }.foregroundColor(.black)
            }
        }
    }
}
