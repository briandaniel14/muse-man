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

struct AppleMusicBadgeRow<Details: View>: View {
    let song: AppleMusicSong?
    @ViewBuilder let details: Details

    var body: some View {
        if let song {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.heroBadgeSpacing) {
                    details
                    AppleMusicBadge(song: song)
                }
                VStack(alignment: .leading, spacing: 12) {
                    details
                    AppleMusicBadge(song: song)
                }
            }
        } else {
            details
        }
    }
}
