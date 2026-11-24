import SwiftUI

struct PracticeEntrySheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var entry: PracticeEntry
    @State private var isConfirmingDelete = false

    var body: some View {
        NavigationStack {
            ScrollView {
                PracticeEntryFields(entry: $entry)
                    .padding(.horizontal, Theme.margin)
            }
            .toolbar {
                MoreMenu(isOnHero: false, placement: .destructiveAction) {
                    Button("Delete Practice Entry", systemImage: "trash", role: .destructive) {
                        isConfirmingDelete = true
                    }
                }
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
            .sheetScreen(title: "Practice Entry")
        }
    }

    private var deleteMessage: String {
        let isLast = library.deletingPracticeEntryDeletesItsSession(id: entry.id)
        let hasRecording = entry.recording != nil
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
    @PracticeNextSetting private var isPracticeNextOn
    @Binding var entry: PracticeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Part") {
                PracticeEntryPartName(part: entry.part)
            }
            FieldRow(label: "Practised") {
                Text(entry.day.formatted(date: .complete, time: .omitted))
            }
            if isPracticeNextOn {
                FieldRow(label: "Rating") {
                    RatingButtons(selection: $entry.rating)
                }
            }
            FieldRow(label: "Note") {
                TextField("Optional", text: $entry.note, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(2...)
            }
            FieldRow(label: "Recording") {
                EntryRecordingField(recording: entry.recording, partID: entry.part?.id) { recording in
                    entry.recording = recording
                } onCapture: { audio, date in
                    addRecording(audio: audio, date: date)
                }
            }
        }
    }

    private func addRecording(audio: Data, date: Date?) {
        guard let partID = entry.part?.id else {
            return
        }
        if let added = try? library.addRecording(audio: audio, date: date, to: partID) {
            entry.recording = added
        }
    }
}
