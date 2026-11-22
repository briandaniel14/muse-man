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
        .paperScreen(title: Destination.collections.title)
    }
}

struct CollectionRow: View {
    @Environment(PracticeLibrary.self) private var library
    let collection: Collection

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(collection.name)
                .font(Theme.body)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(songCount)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }

    private var songCount: String {
        let count = library.songs(in: collection.id).count
        return count == 1 ? "1 Song" : "\(count) Songs"
    }
}
