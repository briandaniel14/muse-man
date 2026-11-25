import SwiftUI

struct AppleMusicBadge: View {
    let song: AppleMusicSong

    var body: some View {
        Link(destination: song.url) {
            Image("ListenOnAppleMusic", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Listen on Apple Music")
    }
}

struct HeroAppleMusicBadge: View {
    let song: AppleMusicSong?

    var body: some View {
        if let song {
            AppleMusicBadge(song: song)
                .padding(.top, Theme.heroBadgeSpacing)
        }
    }
}
