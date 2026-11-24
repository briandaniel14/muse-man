import SwiftUI

struct TimedPracticeSessionSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SettingKey.isPracticeNextOn) private var isPracticeNextOn = true
    let sessionID: PracticeSession.ID
    @State private var picked: [Part] = []
    @State private var drafts: [Part.ID: PracticeEntryDraft] = [:]

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
                    DiscardDraftsButton(title: "Close", draftAudio: draftAudio) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    DiscardDraftsButton(title: "Finish", draftAudio: draftAudio) {
                        try? library.finishPracticeSession(id: sessionID)
                        dismiss()
                    }
                }
            }
            .interactiveDismissDisabled(!draftAudio.isEmpty)
            .sheetScreen(title: "Practice Session")
        }
    }

    private var draftAudio: [Recording] {
        drafts.values.flatMap(\.draftAudio)
    }

    private var entries: [PracticeEntry] {
        library.practiceEntries(in: sessionID)
    }

    private var toPractise: [Part] {
        library.partsToPractise(in: sessionID, picked: picked, includesDue: isPracticeNextOn)
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
    @AppStorage(SettingKey.isPracticeNextOn) private var isPracticeNextOn = true
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
                Text(isPracticeNextOn ? "Nothing Due. Add a Part to practise it." : "Add a Part to practise it.")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(parts) { part in
                DraftEntryRow(entry: draft(for: part), log: {
                    log(drafts.removeValue(forKey: part.id) ?? PracticeEntryDraft(part: part))
                })
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
    @AppStorage(SettingKey.isPracticeNextOn) private var isPracticeNextOn = true
    let entries: [PracticeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("Logged")
                .padding(.bottom, 4)
            Hairline()
            if entries.isEmpty {
                Text(isPracticeNextOn ? "Rate a Part to log it" : "Log a Part to see it here")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            PracticeEntryList(entries: entries, heading: .part)
        }
    }
}
