import SwiftUI

struct TimedPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    let sessionID: PracticeSession.ID
    @State private var picked: [Part] = []
    @State private var drafts: [Part.ID: PracticeEntryDraft] = [:]
    @State private var discardedAudio: [Recording] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    if let session = library.practiceSession(id: sessionID) {
                        ElapsedTime(since: session.startDate, isEmpty: entries.isEmpty)
                    }
                    PendingPartsSection(parts: toPractise, drafts: $drafts, logged: entries, log: log) { part in
                        picked.append(part)
                    }
                    LoggedEntriesSection(entries: entries)
                }
                .padding(.horizontal, Theme.margin)
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        discardedAudio = drafts.values.flatMap(\.unsavedRecordings)
                        if discardedAudio.isEmpty {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Finish") {
                        try? library.finishPracticeSession(id: sessionID)
                        dismiss()
                    }
                }
            }
            .keepAudioPrompt($discardedAudio) {
                dismiss()
            }
            .interactiveDismissDisabled(drafts.values.contains { !$0.unsavedRecordings.isEmpty })
            .sheetScreen(title: "Practice Session")
        }
    }

    private var entries: [PracticeEntry] {
        library.practiceEntries(in: sessionID)
    }

    private var toPractise: [Part] {
        library.partsToPractise(in: sessionID, picked: picked)
    }

    private func log(_ draft: PracticeEntryDraft) {
        _ = try? library.logPracticeEntry(draft, in: sessionID)
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
    @Binding var drafts: [Part.ID: PracticeEntryDraft]
    let logged: [PracticeEntry]
    let log: (PracticeEntryDraft) -> Void
    let pick: (Part) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("To Practise")
                Spacer()
                PartPickerButton(excluding: excluded, choose: pick)
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
                    .onChange(of: drafts[part.id]?.rating) { _, rating in
                        if rating != nil, let draft = drafts.removeValue(forKey: part.id) {
                            log(draft)
                        }
                    }
                Hairline()
            }
        }
    }

    private var excluded: Set<Part.ID> {
        Set(parts.map(\.id) + logged.compactMap(\.part?.id))
    }

    private func draft(for part: Part) -> Binding<PracticeEntryDraft> {
        Binding {
            drafts[part.id] ?? PracticeEntryDraft(part: part)
        } set: { draft in
            drafts[part.id] = draft
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
