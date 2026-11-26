import SwiftUI

struct LogPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @PracticeNextSetting private var isPracticeNextOn
    @State private var details = SessionDetails()
    @State private var entries: [PracticeEntryDraft]

    init(drafts: [PracticeEntryDraft] = []) {
        _entries = State(initialValue: drafts)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    SessionFields(details: $details)
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
        TimeInterval((details.minutes ?? 0) * 60)
    }

    private var isIncomplete: Bool {
        !library.canLogPracticeSession(duration: duration, drafts: entries, isPracticeNextOn: isPracticeNextOn)
    }

    private func save() {
        _ = try? library.logPracticeSession(
            name: details.name,
            startDate: library.startDate(hoursAgo: details.hoursAgo ?? 0, minutesAgo: details.minutesAgo ?? 0),
            duration: duration,
            note: details.note,
            drafts: entries,
            isPracticeNextOn: isPracticeNextOn,
        )
    }
}

struct SessionDetails {
    var name = ""
    var hoursAgo: Int? = 0
    var minutesAgo: Int? = 30
    var minutes: Int? = 30
    var note = ""
}

struct SessionFields: View {
    @Binding var details: SessionDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Name") {
                TextField("Name", text: $details.name, prompt: Text("Untitled").foregroundStyle(Theme.fadedInk))
            }
            FieldRow(label: "Started") {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    NumberField(value: $details.hoursAgo)
                    Text(details.hoursAgo == 1 ? "hour" : "hours")
                    NumberField(value: $details.minutesAgo)
                    Text(details.minutesAgo == 1 ? "minute ago" : "minutes ago")
                }
            }
            FieldRow(label: "Duration") {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    NumberField(value: $details.minutes)
                    Text(details.minutes == 1 ? "minute" : "minutes")
                }
            }
            FieldRow(label: "Note") {
                TextField("Optional", text: $details.note, axis: .vertical)
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
