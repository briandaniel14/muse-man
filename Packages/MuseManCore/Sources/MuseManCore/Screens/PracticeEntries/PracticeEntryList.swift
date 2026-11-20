import SwiftUI

struct PracticeEntryList: View {
    @Environment(PracticeLibrary.self) private var library
    let entries: [PracticeEntry]
    let heading: PracticeEntryRow.Heading
    @State private var editing: PracticeEntry?
    @State private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(entries) { entry in
                HStack {
                    Button {
                        player.stop()
                        editing = entry
                    } label: {
                        PracticeEntryRow(entry: entry, heading: heading)
                    }
                    .buttonStyle(.plain)
                    if let recording = entry.recordingID.flatMap(library.recording(identifier:)) {
                        PlayRecordingButton(recording: recording, player: player)
                    }
                }
                Hairline()
            }
        }
        .sheet(item: $editing) { entry in
            PracticeEntrySheet(entry: entry)
        }
        .onDisappear {
            player.stop()
        }
    }
}

struct PracticeEntryRow: View {
    enum Heading {
        case part
        case day
    }

    let entry: PracticeEntry
    let heading: Heading

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                switch heading {
                case .part:
                    PracticeEntryPartName(partID: entry.partID)
                case .day:
                    Text(entry.day.formatted(date: .abbreviated, time: .omitted))
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.fadedInk)
                }
            }
            Spacer()
            Text(entry.rating.title)
                .font(Theme.caption)
                .foregroundStyle(Theme.accent)
        }
        .padding(.vertical, 12)
        .contentShape(.rect)
    }
}

struct PracticeEntryPartName: View {
    @Environment(PracticeLibrary.self) private var library
    let partID: UUID

    var body: some View {
        if let part = library.part(identifier: partID) {
            VStack(alignment: .leading, spacing: 2) {
                Text(part.song.title)
                Text(part.displayName)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
        } else {
            Text("Deleted Part")
                .foregroundStyle(Theme.fadedInk)
        }
    }
}
