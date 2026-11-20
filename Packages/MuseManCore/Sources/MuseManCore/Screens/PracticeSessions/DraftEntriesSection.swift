import SwiftUI

struct DraftEntriesSection: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var entries: [DraftEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Practice Entries")
                    .font(Theme.title)
                Spacer()
                PartMenu(parts: library.songs().flatMap { library.parts(of: $0.id) }) { part in
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
                DraftEntryRow(entry: $entry) {
                    entries.removeAll { $0.id == entry.id }
                }
                Hairline()
            }
        }
    }
}

struct PartMenu: View {
    let parts: [Part]
    let choose: (Part) -> Void

    var body: some View {
        Menu {
            ForEach(parts) { part in
                Button("\(part.song.title) · \(part.displayName)") {
                    choose(part)
                }
            }
        } label: {
            Label("Add Practice Entry", systemImage: "plus")
                .labelStyle(.iconOnly)
                .foregroundStyle(Theme.accent)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .fixedSize()
        .disabled(parts.isEmpty)
    }
}

struct DraftEntryRow: View {
    @Binding var entry: DraftEntry
    let remove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.part.song.title)
                    Text(entry.part.displayName)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.fadedInk)
                }
                Spacer()
                Button("Remove", systemImage: "xmark", action: remove)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.fadedInk)
            }
            RatingButtons(selection: $entry.rating)
            TextField("Note, optional", text: $entry.note, axis: .vertical)
                .textFieldStyle(.plain)
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
