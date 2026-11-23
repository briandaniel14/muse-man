import SwiftUI

struct LibraryScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var search = ""
    @State private var isAddingSong = false

    var body: some View {
        SongList(songs: library.songs(matching: search), isSearching: !search.isEmpty)
            .searchable(text: $search, prompt: "Title or artist")
            .navigationDestination(for: Song.self) { song in
                SongScreen(song: song)
            }
            .navigationDestination(for: Part.self) { part in
                PartScreen(part: part)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Song", systemImage: "plus") {
                        isAddingSong = true
                    }
                }
            }
            .sheet(isPresented: $isAddingSong) {
                AddSongSheet()
            }
            .paperScreen(title: Destination.library.title)
    }
}

struct SongList: View {
    let songs: [Song]
    let isSearching: Bool

    var body: some View {
        List(songs) { song in
            NavigationLink(value: song) {
                SongRow(song: song)
            }
            .paperRow()
        }
        .id(songs.map(\.id))
        .listStyle(.plain)
        .overlay {
            if songs.isEmpty {
                Text(isSearching ? "No matching Songs" : "No Songs yet")
                    .foregroundStyle(Theme.fadedInk)
            }
        }
    }
}
