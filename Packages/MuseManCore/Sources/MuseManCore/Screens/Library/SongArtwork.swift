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
            ArtworkPlaceholder(size: size)
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * Theme.artworkCornerRadiusRatio))
        .accessibilityHidden(true)
    }
}

struct ArtworkPlaceholder: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Theme.sidebar)
            Image(systemName: "music.note")
                .font(.system(size: size * Theme.artworkPlaceholderIconRatio))
                .foregroundStyle(Theme.hairline)
        }
    }
}
