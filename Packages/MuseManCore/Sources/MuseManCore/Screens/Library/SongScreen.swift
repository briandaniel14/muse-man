import SwiftUI

struct SongScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var song: Song
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                SongFields(title: $song.title, artist: $song.artist, key: $song.key, tempo: $song.tempo)
                SongPartsSection(song: song)
                SongResourcesSection(songID: song.id)
                Button("Delete Song", role: .destructive) {
                    isConfirmingDelete = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, Theme.margin)
        }
        .onChange(of: song) {
            try? library.updateSong(song)
        }
        .confirmationDialog("Delete \(song.title)?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
            Button("Delete Song", role: .destructive) {
                try? library.deleteSong(id: song.id)
                dismiss()
            }
        } message: {
            Text(
                "Its Parts, Recordings, Resources and practice history will be deleted too, "
                    + "and it leaves its Collections. This can't be undone.",
            )
        }
        .paperScreen(title: song.title.isEmpty ? "Song" : song.title)
    }
}
