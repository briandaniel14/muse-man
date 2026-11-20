import SwiftUI

struct PartTitle: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(part.song.title)
            Text(part.displayName)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
    }
}
