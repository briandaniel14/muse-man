import SwiftUI

struct LogPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var hoursAgo: Int? = 0
    @State private var minutesAgo: Int? = 30
    @State private var minutes: Int? = 30
    @State private var note = ""
    @State private var entries: [DraftEntry] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SessionFields(hoursAgo: $hoursAgo, minutesAgo: $minutesAgo, minutes: $minutes, note: $note)
                    DraftEntriesSection(entries: $entries)
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
                        save()
                        dismiss()
                    }
                    .disabled(isIncomplete)
                }
            }
            .sheetScreen(title: "Log Practice Session")
        }
    }

    private var isIncomplete: Bool {
        (minutes ?? 0) == 0 || entries.isEmpty || entries.contains { $0.rating == nil }
    }

    private func save() {
        let minutesAgo = (hoursAgo ?? 0) * 60 + (minutesAgo ?? 0)
        guard let session = try? library.addPracticeSession(
            startDate: library.now().addingTimeInterval(-TimeInterval(minutesAgo * 60)),
            duration: TimeInterval((minutes ?? 0) * 60),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
        ) else {
            return
        }
        for entry in entries {
            guard let rating = entry.rating else {
                continue
            }
            _ = try? library.addPracticeEntry(
                to: session.id,
                part: entry.part.id,
                rating: rating,
                note: entry.note.trimmingCharacters(in: .whitespacesAndNewlines),
                recordingID: entry.recording?.identifier,
            )
        }
        try? library.finishPracticeSession(id: session.id)
    }
}

struct DraftEntry: Identifiable {
    let id = UUID()
    let part: Part
    var rating: Rating?
    var note = ""
    var recording: Recording?
}

struct SessionFields: View {
    @Binding var hoursAgo: Int?
    @Binding var minutesAgo: Int?
    @Binding var minutes: Int?
    @Binding var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Started") {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    NumberField(value: $hoursAgo)
                    Text(hoursAgo == 1 ? "hour" : "hours")
                    NumberField(value: $minutesAgo)
                    Text(minutesAgo == 1 ? "minute ago" : "minutes ago")
                }
            }
            FieldRow(label: "Duration") {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    NumberField(value: $minutes)
                    Text(minutes == 1 ? "minute" : "minutes")
                }
            }
            FieldRow(label: "Note") {
                TextField("Optional", text: $note, axis: .vertical)
                    .lineLimit(2...)
            }
        }
        .textFieldStyle(.plain)
    }
}

struct NumberField: View {
    @Binding var value: Int?

    var body: some View {
        TextField("0", text: $value.digits)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .frame(width: 48)
            .padding(.vertical, 4)
            .background(Theme.sidebar, in: .rect(cornerRadius: 6))
        #if os(iOS)
            .keyboardType(.numberPad)
        #endif
    }
}
