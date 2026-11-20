import SwiftUI

struct SongPartRow: View {
    let part: Part

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(part.song.title)
                    .foregroundStyle(Theme.ink)
                Text(part.displayName)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            Spacer()
            Text(part.status.title)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }
}
