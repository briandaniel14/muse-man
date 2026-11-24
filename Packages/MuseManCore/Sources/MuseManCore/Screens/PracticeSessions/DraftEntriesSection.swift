import SwiftUI

struct DraftEntriesSection: View {
    @Binding var entries: [PracticeEntryDraft]
    @State private var draftAudio: [Recording] = []

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
                    draftAudio = entry.draftAudio
                    entries.removeAll { $0.id == entry.id }
                }
                Hairline()
            }
        }
        .keepAudioPrompt($draftAudio)
    }
}

struct DraftEntryRow: View {
    @Environment(PracticeLibrary.self) private var library
    @AppStorage(SettingKey.isPracticeNextOn) private var asksForRating = true
    @Binding var entry: PracticeEntryDraft
    var remove: (() -> Void)?
    var log: (() -> Void)?
    @State private var draftAudio: [Recording] = []

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
                draftAudio = entry.replaceRecording(with: recording)
            } onCapture: { audio, date in
                draftAudio = (try? library.replaceRecording(of: &entry, withAudio: audio, date: date)) ?? []
            }
            if asksForRating {
                RatingButtons(selection: $entry.rating)
            } else if let log {
                Button(action: log) {
                    PillLabel(title: "Log", isSelected: false)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .keepAudioPrompt($draftAudio)
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
                    PillLabel(title: rating.title, isSelected: selection == rating)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct PillLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(Theme.caption)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .foregroundStyle(isSelected ? Theme.paper : Theme.ink)
            .background(isSelected ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(.clear))
            .overlay(Capsule().stroke(Theme.hairline))
            .clipShape(.capsule)
    }
}
