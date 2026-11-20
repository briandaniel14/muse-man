import SwiftUI

struct DuePartRow: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(part.song.title)
                .foregroundStyle(Theme.ink)
            Text(part.displayName)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }
}
