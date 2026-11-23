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
            ZStack {
                Rectangle()
                    .fill(Theme.sidebar)
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.4))
                    .foregroundStyle(Theme.hairline)
            }
        }
        .frame(width: size, height: size)
        .clipShape(.rect(cornerRadius: size * 0.1))
        .accessibilityHidden(true)
    }
}
