import SwiftUI

struct CollectionsScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var isAddingCollection = false

    var body: some View {
        let collections = library.collections()
        List(collections) { collection in
            NavigationLink(value: collection) {
                CollectionRow(collection: collection)
            }
            .paperRow()
        }
        .listStyle(.plain)
        #if os(macOS)
            .safeAreaPadding(.top, Theme.listTopInset)
        #endif
            .overlay {
                if collections.isEmpty {
                    Text("No Collections yet")
                        .foregroundStyle(Theme.fadedInk)
                }
            }
            .navigationDestination(for: Collection.self) { collection in
                CollectionScreen(collection: collection)
            }
            .navigationDestination(for: Song.self) { song in
                SongScreen(song: song)
            }
            .navigationDestination(for: Part.self) { part in
                PartScreen(part: part)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Collection", systemImage: "plus") {
                        isAddingCollection = true
                    }
                }
            }
            .sheet(isPresented: $isAddingCollection) {
                AddCollectionSheet()
            }
            .paperScreen(title: Destination.collections.title, isFullWidth: true)
    }
}

struct CollectionRow: View {
    @Environment(PracticeLibrary.self) private var library
    let collection: Collection

    var body: some View {
        let songs = library.songs(in: collection.id)
        HStack(spacing: Theme.rowSpacing) {
            CoverGrid(songs: songs, size: Theme.rowArtworkSize)
            Text(collection.name)
                .font(Theme.body)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(songCount: songs.count)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }
}

extension Text {
    init(songCount: Int) {
        self.init("^[\(songCount) Song](inflect: true)")
    }
}
