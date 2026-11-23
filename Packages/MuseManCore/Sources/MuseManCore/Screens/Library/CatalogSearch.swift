import SwiftUI

struct CatalogSearch: View {
    @Binding var search: String
    let choose: (CatalogSong, [CatalogSong]) -> Void
    @State private var results: [CatalogSong] = []
    @State private var isSearching = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchField(prompt: "Search Apple Music", text: $search)
                .padding(.vertical, 12)
            if !search.isEmpty {
                ForEach(results) { result in
                    Button {
                        choose(result, results)
                    } label: {
                        CatalogSongRow(song: result)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    Hairline()
                }
                if results.isEmpty {
                    Text(isSearching ? "Searching…" : "No matches")
                        .foregroundStyle(Theme.fadedInk)
                        .padding(.vertical, 12)
                }
            }
        }
        .task {
            await SongCatalog.warmUp()
        }
        .task(id: search) {
            await find(search)
        }
    }

    private func find(_ term: String) async {
        let term = term.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else {
            results = []
            return
        }
        isSearching = true
        guard await (try? Task.sleep(for: .milliseconds(150))) != nil else {
            return
        }
        let found = await SongCatalog.search(term)
        guard !Task.isCancelled else {
            return
        }
        results = found
        isSearching = false
    }
}

struct CatalogSongRow: View {
    let song: CatalogSong

    var body: some View {
        HStack(spacing: 12) {
            SongArtwork(url: song.thumbnailURL, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(Theme.body)
                    .foregroundStyle(Theme.ink)
                Text([song.artist, song.album].compactMap(\.self).joined(separator: " · "))
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            .lineLimit(1)
            Spacer()
            Image(systemName: "plus")
                .foregroundStyle(Theme.accent)
        }
        .padding(.vertical, 8)
    }
}
