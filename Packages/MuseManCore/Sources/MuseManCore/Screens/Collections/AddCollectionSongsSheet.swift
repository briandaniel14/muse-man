import SwiftUI

struct AddCollectionSongsSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment
    let collectionID: Collection.ID
    @State private var search = ""

    var body: some View {
        NavigationStack {
            let songs = availableSongs
            List(songs) { song in
                Button {
                    try? library.addSong(song.id, to: collectionID)
                } label: {
                    HStack {
                        SongRow(song: song)
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.accent)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .modifier(CollectionListRowStyle(environment: environment))
            }
            .listStyle(.plain)
            .overlay {
                if songs.isEmpty {
                    Text(search.isEmpty ? "Every Song is in this Collection" : "No matching Songs")
                        .foregroundStyle(Theme.fadedInk)
                }
            }
            .searchable(text: $search, prompt: "Title or artist")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .paperScreen(title: "Add Songs")
        }
    }

    private var availableSongs: [Song] {
        let added = Set(library.songs(in: collectionID).map(\.id))
        return library.songs(matching: search).filter { !added.contains($0.id) }
    }
}
