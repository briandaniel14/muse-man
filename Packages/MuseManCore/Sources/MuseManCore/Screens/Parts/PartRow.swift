import SwiftUI

struct PartRow: View {
    let part: Part

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(part.displayName)
                .foregroundStyle(Theme.ink)
            Spacer()
            Text(part.status.title)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 12)
        .contentShape(.rect)
    }
}

extension Part {
    var displayName: String {
        [instrument.name, label]
            .compactMap(\.self)
            .joined(separator: " · ")
    }
}
