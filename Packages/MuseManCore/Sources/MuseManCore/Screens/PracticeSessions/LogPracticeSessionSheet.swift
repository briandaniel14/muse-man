import SwiftUI

struct LogPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var startDate = Date()
    @State private var minutes: Int? = 30
    @State private var note = ""
    @State private var entries: [DraftEntry] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SessionFields(startDate: $startDate, minutes: $minutes, note: $note)
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
            .paperScreen(title: "Log Practice Session")
        }
    }

    private var isIncomplete: Bool {
        (minutes ?? 0) == 0 || entries.isEmpty || entries.contains { $0.rating == nil }
    }

    private func save() {
        guard let session = try? library.addPracticeSession(
            startDate: startDate,
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
}

struct SessionFields: View {
    @Binding var startDate: Date
    @Binding var minutes: Int?
    @Binding var note: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Started") {
                DatePicker("Started", selection: $startDate, in: ...Date())
                    .labelsHidden()
                    .fixedSize()
            }
            FieldRow(label: "Duration (minutes)") {
                TextField("Minutes", text: minutesText)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
            }
            FieldRow(label: "Note") {
                TextField("Optional, such as tired, fingers sore", text: $note, axis: .vertical)
                    .lineLimit(2...)
            }
        }
        .textFieldStyle(.plain)
    }

    private var minutesText: Binding<String> {
        Binding {
            minutes.map(String.init) ?? ""
        } set: {
            minutes = Int($0.filter(\.isNumber))
        }
    }
}
