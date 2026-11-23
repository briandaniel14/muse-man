import SwiftUI

struct PartTitle: View {
    let part: Part

    var body: some View {
        HStack(spacing: 12) {
            SongArtwork(url: part.song.artworkURL, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(part.song.title)
                    .font(Theme.body)
                Text(part.displayName)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
        }
    }
}
