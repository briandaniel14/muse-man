import SwiftUI

struct PracticeEntrySheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var entry: PracticeEntry
    @State private var isConfirmingDelete = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    PracticeEntryFields(entry: $entry)
                    Button("Delete Practice Entry", role: .destructive) {
                        isConfirmingDelete = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red)
                }
                .padding(.horizontal, Theme.margin)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        entry.note = entry.note.trimmingCharacters(in: .whitespacesAndNewlines)
                        try? library.updatePracticeEntry(entry)
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                "Delete Practice Entry?",
                isPresented: $isConfirmingDelete,
                titleVisibility: .visible,
            ) {
                Button("Delete Practice Entry", role: .destructive) {
                    try? library.deletePracticeEntry(id: entry.id)
                    dismiss()
                }
            } message: {
                Text(deleteMessage)
            }
            .paperScreen(title: "Practice Entry")
        }
    }

    private var deleteMessage: String {
        let isLast = library.practiceSession(id: entry.session)?.duration != nil
            && library.practiceEntries(in: entry.session).count == 1
        return isLast
            ? "It's the only Practice Entry in its Practice Session, so that goes too. This can't be undone."
            : "This can't be undone."
    }
}

struct PracticeEntryFields: View {
    @Binding var entry: PracticeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Part") {
                PracticeEntryPartName(partID: entry.partID)
            }
            FieldRow(label: "Practised") {
                Text(entry.day.formatted(date: .complete, time: .omitted))
            }
            FieldRow(label: "Rating") {
                RatingButtons(selection: rating)
            }
            FieldRow(label: "Note") {
                TextField("Optional", text: $entry.note, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...)
            }
        }
    }

    private var rating: Binding<Rating?> {
        Binding {
            entry.rating
        } set: { rating in
            if let rating {
                entry.rating = rating
            }
        }
    }
}
