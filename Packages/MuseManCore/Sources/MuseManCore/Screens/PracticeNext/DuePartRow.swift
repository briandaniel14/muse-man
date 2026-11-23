import SwiftUI

struct DuePartRow: View {
    let part: Part

    var body: some View {
        PartTitle(part: part)
            .foregroundStyle(Theme.ink)
            .padding(.vertical, 4)
    }
}
