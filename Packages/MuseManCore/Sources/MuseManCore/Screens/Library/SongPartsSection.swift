import SwiftUI

struct SongPartsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let song: Song
    @State private var isAddingPart = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Parts")
                    .font(Theme.title)
                Spacer()
                Button("Add Part", systemImage: "plus") {
                    isAddingPart = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
            }
            .padding(.bottom, 4)
            Hairline()
            ForEach(library.parts(of: song.id)) { part in
                NavigationLink(value: part) {
                    PartRow(part: part)
                }
                .buttonStyle(.plain)
                Hairline()
            }
        }
        .sheet(isPresented: $isAddingPart) {
            AddPartSheet(song: song)
        }
    }
}
