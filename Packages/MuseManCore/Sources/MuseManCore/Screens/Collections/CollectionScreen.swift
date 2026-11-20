import SwiftUI

struct CollectionScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @Environment(\.self) private var environment
    @State var collection: Collection
    @State private var isAddingSongs = false
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 4) {
                Text("Name")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
                TextField("Name", text: $collection.name)
                    .textFieldStyle(.plain)
            }
            .padding(.vertical, 4)
            .modifier(CollectionListRowStyle(environment: environment))
            CollectionSongs(collectionID: collection.id)
            Button("Delete Collection", role: .destructive) {
                isConfirmingDelete = true
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .padding(.top, 20)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .onChange(of: collection) {
            try? library.updateCollection(collection)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                #if os(iOS)
                    EditButton()
                #endif
                Button("Add Songs", systemImage: "plus") {
                    isAddingSongs = true
                }
            }
        }
        .sheet(isPresented: $isAddingSongs) {
            AddCollectionSongsSheet(collectionID: collection.id)
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
        .paperScreen(title: collection.name.isEmpty ? "Collection" : collection.name)
    }
}

struct CollectionSongs: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.self) private var environment
    let collectionID: Collection.ID

    var body: some View {
        let songs = library.songs(in: collectionID)
        Text("Songs")
            .font(Theme.title)
            .padding(.top, 20)
            .modifier(CollectionListRowStyle(environment: environment))
        if songs.isEmpty {
            Text("No Songs yet")
                .foregroundStyle(Theme.fadedInk)
                .modifier(CollectionListRowStyle(environment: environment))
        }
        ForEach(songs) { song in
            NavigationLink(value: song) {
                CollectionSongRow(song: song)
            }
            .swipeActions {
                Button("Remove", systemImage: "minus.circle", role: .destructive) {
                    try? library.removeSong(song.id, from: collectionID)
                }
            }
            .modifier(CollectionListRowStyle(environment: environment))
        }
        .onMove { offsets, destination in
            try? library.moveSongs(in: collectionID, fromOffsets: offsets, toOffset: destination)
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

struct CollectionListRowStyle: ViewModifier {
    let environment: EnvironmentValues

    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Theme.hairline.resolve(in: environment))
    }
}
