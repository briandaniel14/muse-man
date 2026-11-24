import SwiftUI

struct LogPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingKey.isPracticeNextOn) private var isPracticeNextOn = true
    @State private var hoursAgo: Int? = 0
    @State private var minutesAgo: Int? = 30
    @State private var minutes: Int? = 30
    @State private var note = ""
    @State private var entries: [PracticeEntryDraft] = []

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
                    DiscardDraftsButton(title: "Cancel", draftAudio: draftAudio) {
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
            .interactiveDismissDisabled(!draftAudio.isEmpty)
            .sheetScreen(title: "Log Practice Session")
        }
    }

    private var draftAudio: [Recording] {
        entries.flatMap(\.draftAudio)
    }

    private var duration: TimeInterval {
        TimeInterval((minutes ?? 0) * 60)
    }

    private var isIncomplete: Bool {
        !library.canLogPracticeSession(duration: duration, drafts: entries, isPracticeNextOn: isPracticeNextOn)
    }

    private func save() {
        _ = try? library.logPracticeSession(
            startDate: library.startDate(hoursAgo: hoursAgo ?? 0, minutesAgo: minutesAgo ?? 0),
            duration: duration,
            note: note,
            drafts: entries,
            isPracticeNextOn: isPracticeNextOn,
        )
    }
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
