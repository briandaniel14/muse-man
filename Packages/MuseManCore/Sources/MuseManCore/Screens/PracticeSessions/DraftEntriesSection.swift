import SwiftUI

struct DraftEntriesSection: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var entries: [PracticeEntryDraft]
    @State private var removedAudio: [Recording] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                SectionTitle("Practice Entries")
                Spacer()
                PartPickerButton(excluding: Set(entries.map(\.part.id))) { part in
                    entries.append(PracticeEntryDraft(part: part))
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
                DraftEntryRow(entry: $entry) {
                    removedAudio = entry.unsavedRecordings
                    entries.removeAll { $0.id == entry.id }
                }
                Hairline()
            }
        }
        .keepAudioPrompt($removedAudio)
    }
}

struct DraftEntryRow: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var entry: PracticeEntryDraft
    var remove: (() -> Void)?
    @State private var replacedAudio: [Recording] = []

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
            EntryRecordingField(recording: entry.recording, partID: entry.part.id) { recording in
                replacedAudio = entry.replaceRecording(with: recording)
            } onCapture: { audio, date in
                replacedAudio = (try? library.replaceRecording(of: &entry, withAudio: audio, date: date)) ?? []
            }
            RatingButtons(selection: $entry.rating)
        }
        .padding(.vertical, 12)
        .keepAudioPrompt($replacedAudio)
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
