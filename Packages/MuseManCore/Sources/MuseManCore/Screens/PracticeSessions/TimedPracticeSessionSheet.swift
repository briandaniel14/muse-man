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
            .paperScreen(title: "Practice Session")
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
    @State private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("To Practise")
                    .font(Theme.title)
                Spacer()
                PartMenu(parts: library.parts(), choose: pick)
            }
            .padding(.bottom, 4)
            Hairline()
            if parts.isEmpty {
                Text("Nothing Due. Add a Part to practise it.")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(parts) { part in
                PendingEntryRow(part: part, player: player) { rating, note, recordingID in
                    log(part, rating, note, recordingID)
                }
                Hairline()
            }
        }
        .onDisappear {
            player.stop()
        }
    }
}

struct PendingEntryRow: View {
    let part: Part
    let player: AudioPlayer
    let log: (Rating, String, UUID?) -> Void
    @State private var note = ""
    @State private var recordingID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PartTitle(part: part)
            TextField("Note, optional", text: $note, axis: .vertical)
                .textFieldStyle(.plain)
            EntryRecordingField(recordingID: $recordingID, partID: part.id, player: player)
            RatingButtons(selection: rating)
        }
        .padding(.vertical, 12)
    }

    private var rating: Binding<Rating?> {
        Binding {
            nil
        } set: { rating in
            if let rating {
                player.stop()
                log(rating, note.trimmingCharacters(in: .whitespacesAndNewlines), recordingID)
            }
        }
    }
}

struct LoggedEntriesSection: View {
    let entries: [PracticeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Logged")
                .font(Theme.title)
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
