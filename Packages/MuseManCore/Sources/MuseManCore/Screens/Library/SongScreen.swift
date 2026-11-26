import SwiftUI

struct SongScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var song: Song
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SongHero(song: $song)
                TwoColumns {
                    SongPartsSection(song: song)
                } trailing: {
                    SongResourcesSection(songID: song.id)
                }
            }
        }
        .playbackBar(for: song.appleMusicSong)
        .onChange(of: song) {
            try? library.updateSong(song)
        }
        .toolbar {
            MoreMenu {
                Button("Delete Song", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
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
        .heroScreen(title: song.title.isEmpty ? "Song" : song.title)
    }
}

struct SongHero: View {
    @Binding var song: Song

    var body: some View {
        ArtworkHero(artworkURL: song.artworkURL) {
            VStack(alignment: .leading, spacing: 8) {
                HeroTextField(label: "Title", placeholder: "Title", text: $song.title, axis: .vertical)
                    .font(Theme.heroTitle)
                HeroTextField(label: "Artist", placeholder: "Artist", text: $song.artist)
                    .font(Theme.heroSubtitle)
            }
        } panel: {
            HeroPanel {
                AppleMusicBadgeRow(song: song.appleMusicSong) {
                    HStack(alignment: .top, spacing: 48) {
                        HeroDetail(label: "Key", systemImage: "music.quarternote.3") {
                            HeroTextField(label: "Key", placeholder: "Add", text: $song.key.orEmpty)
                        }
                        .fixedSize()
                        HeroDetail(label: "Tempo", systemImage: "metronome") {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                HeroTextField(label: "Tempo", placeholder: "Add", text: $song.tempo.digits)
                                #if os(iOS)
                                    .keyboardType(.numberPad)
                                #endif
                                Text("BPM")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.bandFadedInk)
                                    .fixedSize()
                            }
                        }
                        .fixedSize()
                    }
                }
                HeroDetail(label: "Song Note", systemImage: "note.text") {
                    HeroTextField(
                        label: "Song Note",
                        placeholder: "Structure, reminders…",
                        text: $song.note,
                        axis: .vertical,
                    )
                    .lineLimit(2...)
                }
            }
        }
    }
}
