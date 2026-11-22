import SwiftUI

struct DraftEntriesSection: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var entries: [DraftEntry]
    @State private var player = AudioPlayer()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("Practice Entries")
                Spacer()
                PartPickerButton(excluding: Set(entries.map(\.part.id))) { part in
                    entries.append(DraftEntry(part: part))
                }
            }
            .padding(.bottom, 4)
            Hairline()
            if entries.isEmpty {
                Text("Add the Parts you practised")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach($entries) { $entry in
                DraftEntryRow(entry: $entry, player: player) {
                    entries.removeAll { $0.id == entry.id }
                }
                Hairline()
            }
        }
        .onDisappear {
            player.stop()
        }
    }
}

struct DraftEntryRow: View {
    @Binding var entry: DraftEntry
    let player: AudioPlayer
    var remove: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                PartTitle(part: entry.part)
                Spacer()
                if let remove {
                    Button("Remove", systemImage: "xmark", action: remove)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.plain)
                        .foregroundStyle(Theme.fadedInk)
                }
            }
            TextField("Note, optional", text: $entry.note, axis: .vertical)
                .textFieldStyle(.plain)
            EntryRecordingField(recordingID: $entry.recordingID, partID: entry.part.id, player: player)
            RatingButtons(selection: $entry.rating)
        }
        .padding(.vertical, 12)
    }
}

struct RatingButtons: View {
    @Binding var selection: Rating?

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Rating.allCases) { rating in
                Button {
                    selection = rating
                } label: {
                    Text(rating.title)
                        .font(Theme.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundStyle(selection == rating ? Theme.paper : Theme.ink)
                        .background(selection == rating ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(.clear))
                        .overlay(Capsule().stroke(Theme.hairline))
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
