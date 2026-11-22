import SwiftUI

struct AddCollectionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                FieldRow(label: "Name") {
                    TextField("Such as Friday Gig", text: $name)
                }
                .textFieldStyle(.plain)
                .padding(.horizontal, Theme.margin)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _ = try? library.addCollection(name: trimmedName)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .sheetScreen(title: "New Collection")
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }
}
