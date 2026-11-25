import SwiftUI

struct CollectionScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var collection: Collection
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CollectionHero(collection: $collection)
                PageColumn {
                    CollectionSongs(collectionID: collection.id)
                }
            }
        }
        .onChange(of: collection) {
            try? library.updateCollection(collection)
        }
        .toolbar {
            MoreMenu {
                Button("Delete Collection", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .confirmationDialog(
            "Delete \(collection.name)?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete Collection", role: .destructive) {
                try? library.deleteCollection(id: collection.id)
                dismiss()
            }
        } message: {
            Text("Its Songs stay in the Library.")
        }
        .heroScreen(title: collection.name.isEmpty ? "Collection" : collection.name)
    }
}

struct CollectionSongs: View {
    @Environment(PracticeLibrary.self) private var library
    let collectionID: Collection.ID

    var body: some View {
        let songs = library.songs(in: collectionID)
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionTitle("Songs")
                Spacer()
                AddPopoverButton(title: "Add Songs") {
                    SearchPicker(
                        prompt: "Title or artist",
                        emptyText: "Every Song is in this Collection",
                        items: { search in
                            library.songs(matching: search).filter { !songs.map(\.id).contains($0.id) }
                        },
                        choose: { song in
                            try? library.addSong(song.id, to: collectionID)
                        },
                        label: { song in
                            SongRow(song: song)
                        },
                    )
                }
            }
            .padding(.bottom, 4)
            Hairline()
            if songs.isEmpty {
                Text("No Songs yet")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                NavigationLink(value: song) {
                    CollectionSongRow(song: song)
                        .padding(.vertical, 12)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .draggable(song.dragIdentifier)
                .dropDestination(for: String.self) { identifiers, _ in
                    move(identifiers.first, to: index, in: songs)
                }
                .contextMenu {
                    Button("Remove from Collection", systemImage: "minus.circle", role: .destructive) {
                        try? library.removeSong(song.id, from: collectionID)
                    }
                }
                Hairline()
            }
        }
    }

    private func move(_ identifier: String?, to index: Int, in songs: [Song]) {
        guard let source = songs.firstIndex(where: { $0.dragIdentifier == identifier }), source != index else {
            return
        }
        try? library.moveSongs(in: collectionID, fromOffsets: [source], toOffset: index > source ? index + 1 : index)
    }
}

private extension Song {
    var dragIdentifier: String {
        id.uriRepresentation().absoluteString
    }
}

struct CollectionHero: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var collection: Collection

    var body: some View {
        let songs = library.songs(in: collection.id)
        ArtworkHero {
            VStack(alignment: .leading, spacing: 8) {
                HeroTextField(label: "Name", placeholder: "Name", text: $collection.name, axis: .vertical)
                    .font(Theme.heroTitle)
                Text(songCount: songs.count)
                    .font(Theme.heroSubtitle)
            }
        } panel: {
            HeroPanel {
                HeroDetail(label: "Collection Note", systemImage: "note.text") {
                    HeroTextField(
                        label: "Collection Note",
                        placeholder: "What to bring, reminders…",
                        text: $collection.note,
                        axis: .vertical,
                    )
                    .lineLimit(2...)
                }
            }
        } artwork: { size in
            CoverGrid(songs: songs, size: size)
        }
    }
}

struct CollectionSongRow: View {
    @Environment(PracticeLibrary.self) private var library
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SongRow(song: song)
            let parts = library.parts(of: song.id)
            if parts.isEmpty {
                Text("No Parts")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            ForEach(parts) { part in
                HStack(alignment: .firstTextBaseline) {
                    Text(part.displayName)
                    Spacer()
                    Text(part.status.title)
                }
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
            }
        }
        .padding(.bottom, 4)
    }
}
