import SwiftUI

struct AddSongSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""
    @State private var isrcs: [String] = []
    @State private var title = ""
    @State private var artist = ""
    @State private var key: String?
    @State private var tempo: Int?
    @State private var artworkURL: URL?
    @State private var isAdded = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CatalogSearch(search: $search, choose: choose)
                    if search.isEmpty {
                        if artworkURL != nil {
                            SongArtwork(url: artworkURL, size: 160)
                                .padding(.vertical, 12)
                        }
                        SongFields(title: $title, artist: $artist, key: $key, tempo: $tempo)
                    }
                }
                .padding(.horizontal, Theme.margin)
            }
            .task(id: isrcs) {
                await fillDetails(from: isrcs)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        guard !isAdded else {
                            return
                        }
                        isAdded = true
                        _ = try? library.addSong(
                            title: title,
                            artist: artist,
                            key: key,
                            tempo: tempo,
                            artworkURL: artworkURL,
                        )
                        dismiss()
                    }
                    .disabled(isIncomplete || isAdded)
                }
            }
            .sheetScreen(title: "New Song")
        }
    }

    private var isIncomplete: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty || artist.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func choose(_ song: CatalogSong, from results: [CatalogSong]) {
        isrcs = song.versionISRCs(in: results)
        title = song.title
        artist = song.artist
        artworkURL = song.artworkURL
        search = ""
    }

    private func fillDetails(from isrcs: [String]) async {
        guard !isrcs.isEmpty else {
            return
        }
        key = nil
        tempo = nil
        let details = await SongCatalog.details(isrcs: isrcs)
        guard !Task.isCancelled else {
            return
        }
        key = details?.key
        tempo = details?.tempo
    }
}
