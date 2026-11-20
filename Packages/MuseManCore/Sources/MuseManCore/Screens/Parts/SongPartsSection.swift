import SwiftUI

struct SongPartsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let song: Song

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Parts")
                .font(Theme.title)
                .padding(.bottom, 4)
            Hairline()
            let parts = library.parts(of: song.id)
            if parts.isEmpty {
                Text("No Parts yet")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(parts) { part in
                NavigationLink(value: part) {
                    PartRow(part: part)
                }
                .buttonStyle(.plain)
                Hairline()
            }
        }
    }
}
