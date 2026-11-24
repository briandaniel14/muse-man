import SwiftUI

struct SongArtwork: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ArtworkPlaceholder(iconSize: size * 0.4)
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * 0.1))
        .accessibilityHidden(true)
    }
}

struct ArtworkPlaceholder: View {
    let iconSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Theme.sidebar)
            Image(systemName: "music.note")
                .font(.system(size: iconSize))
                .foregroundStyle(Theme.hairline)
        }
    }
}
