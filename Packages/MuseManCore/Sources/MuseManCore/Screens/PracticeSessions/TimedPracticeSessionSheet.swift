import SwiftUI

struct TimedPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    let sessionID: PracticeSession.ID
    @State private var picked: [Part] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if let session = library.practiceSession(id: sessionID) {
                        ElapsedTime(since: session.startDate, isEmpty: entries.isEmpty)
                    }
                    PendingPartsSection(parts: pending, log: log) { part in
                        if !pending.contains(part) {
                            picked.append(part)
                        }
                    }
                    LoggedEntriesSection(entries: entries)
                }
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") {
                        try? library.finishPracticeSession(id: sessionID)
                        dismiss()
                    }
                }
            }
            .sheetScreen(title: "Practice Session")
        }
    }

    private var entries: [PracticeEntry] {
        library.practiceEntries(in: sessionID)
    }

    private var pending: [Part] {
        let due = library.practiceNext()
        return due + picked.filter { !due.contains($0) }
    }

    private func log(_ part: Part, _ rating: Rating, _ note: String, _ recordingID: UUID?) {
        _ = try? library.addPracticeEntry(
            to: sessionID,
            part: part.id,
            rating: rating,
            note: note,
            recordingID: recordingID,
        )
        picked.removeAll { $0.id == part.id }
    }
}

struct ElapsedTime: View {
    let since: Date
    let isEmpty: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(elapsed(at: context.date))
                    .font(Theme.largeTitle)
                    .monospacedDigit()
            }
            Text(caption)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.top, 16)
    }

    private func elapsed(at date: Date) -> String {
        Duration.seconds(max(0, date.timeIntervalSince(since))).formatted(.time(pattern: .hourMinuteSecond))
    }

    private var caption: String {
        isEmpty
            ? "Finishing with no Practice Entries discards it"
            : "Started \(since.formatted(date: .omitted, time: .shortened))"
    }
}

struct PendingPartsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let parts: [Part]
    let log: (Part, Rating, String, UUID?) -> Void
    let pick: (Part) -> Void
    @State private var drafts: [Part.ID: DraftEntry] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("To Practise")
                Spacer()
                PartPickerButton(excluding: Set(parts.map(\.id)), choose: pick)
            }
            .padding(.bottom, 4)
            Hairline()
            if parts.isEmpty {
                Text("Nothing Due. Add a Part to practise it.")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(parts) { part in
                DraftEntryRow(entry: draft(for: part))
                Hairline()
            }
        }
    }

    private func draft(for part: Part) -> Binding<DraftEntry> {
        Binding {
            drafts[part.id] ?? DraftEntry(part: part)
        } set: { draft in
            guard let rating = draft.rating else {
                drafts[part.id] = draft
                return
            }
            drafts[part.id] = nil
            log(part, rating, draft.note.trimmingCharacters(in: .whitespacesAndNewlines), draft.recordingID)
        }
    }
}

struct LoggedEntriesSection: View {
    let entries: [PracticeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("Logged")
                .padding(.bottom, 4)
            Hairline()
            if entries.isEmpty {
                Text("Rate a Part to log it")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            PracticeEntryList(entries: entries, heading: .part)
        }
    }
}
