import SwiftUI

struct PracticeEntryList: View {
    let entries: [PracticeEntry]
    let heading: PracticeEntryRow.Heading
    @State private var editing: PracticeEntry?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(entries) { entry in
                HStack {
                    Button {
                        editing = entry
                    } label: {
                        PracticeEntryRow(entry: entry, heading: heading)
                    }
                    .buttonStyle(.plain)
                    if let recording = entry.recording {
                        PlayRecordingButton(recording: recording)
                    }
                }
                Hairline()
            }
        }
        .sheet(item: $editing) { entry in
            PracticeEntrySheet(entry: entry)
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
                    PracticeEntryPartName(part: entry.part)
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
            if let rating = entry.rating {
                Text(rating.title)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 12)
        .contentShape(.rect)
    }
}

struct PracticeEntryPartName: View {
    let part: Part?

    var body: some View {
        if let part {
            PartTitle(part: part)
        } else {
            Text("Deleted Part")
                .foregroundStyle(Theme.fadedInk)
        }
    }
}
