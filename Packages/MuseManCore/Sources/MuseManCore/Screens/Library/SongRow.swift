import SwiftUI

struct SongRow: View {
    let song: Song

    var body: some View {
        HStack(spacing: Theme.rowSpacing) {
            SongArtwork(url: song.artworkURL, size: Theme.rowArtworkSize)
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(Theme.body)
                    .foregroundStyle(Theme.ink)
                Text(song.artist)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            Spacer()
            Text(details)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }

    private var details: String {
        [song.key, song.tempo.map { "\($0) BPM" }]
            .compactMap(\.self)
            .joined(separator: " · ")
    }
}
