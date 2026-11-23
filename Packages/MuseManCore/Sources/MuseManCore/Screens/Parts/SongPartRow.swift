import SwiftUI

struct SongPartRow: View {
    let part: Part

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            PartTitle(part: part)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(part.status.title)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 4)
    }
}
