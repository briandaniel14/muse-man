import SwiftUI

struct PracticeEntrySheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var entry: PracticeEntry
    @State private var isConfirmingDelete = false
    @State private var player = AudioPlayer()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    PracticeEntryFields(entry: $entry, player: player)
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
            .onDisappear {
                player.stop()
            }
            .paperScreen(title: "Practice Entry")
        }
    }

    private var deleteMessage: String {
        let isLast = library.deletingPracticeEntryDeletesItsSession(id: entry.id)
        let hasRecording = entry.recordingID.flatMap(library.recording(identifier:)) != nil
        return [
            isLast ? "It's the only Practice Entry in its Practice Session, so that goes too." : nil,
            hasRecording ? "Its Recording stays on the Part." : nil,
            "This can't be undone.",
        ]
        .compactMap(\.self)
        .joined(separator: " ")
    }
}

struct PracticeEntryFields: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var entry: PracticeEntry
    let player: AudioPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Part") {
                PracticeEntryPartName(partIdentifier: entry.partIdentifier)
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
            FieldRow(label: "Recording") {
                EntryRecordingField(
                    recordingID: $entry.recordingID,
                    partID: library.part(identifier: entry.partIdentifier)?.id,
                    player: player,
                )
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
