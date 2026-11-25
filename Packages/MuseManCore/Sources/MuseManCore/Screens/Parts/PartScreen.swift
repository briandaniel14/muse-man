import SwiftUI

struct PartScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var part: Part
    @State private var isConfirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PartHero(part: $part)
                PageColumn {
                    PartRecordingsSection(part: part)
                    PartHistorySection(partID: part.id)
                }
            }
        }
        .playbackBar(for: part.song.appleMusicSong)
        .onChange(of: part) {
            try? library.updatePart(part)
        }
        .toolbar {
            MoreMenu {
                Button("Delete Part", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .confirmationDialog(
            "Delete \(part.displayName)?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete Part", role: .destructive) {
                try? library.deletePart(id: part.id)
                dismiss()
            }
        } message: {
            Text("Its Recordings and practice history will be deleted too. This can't be undone.")
        }
        .heroScreen(title: part.displayName)
    }
}

struct PartHero: View {
    @Binding var part: Part

    var body: some View {
        ArtworkHero(artworkURL: part.song.artworkURL) {
            VStack(alignment: .leading, spacing: 8) {
                Text(part.song.title)
                    .font(Theme.heroTitle)
                Text(part.displayName)
                    .font(Theme.heroSubtitle)
                HeroAppleMusicBadge(song: part.song.appleMusicSong)
            }
        } panel: {
            HeroPanel {
                HeroDetail(label: "Status", systemImage: "chart.line.uptrend.xyaxis") {
                    StatusChips(status: $part.status)
                        .padding(.top, 4)
                }
                HeroDetail(label: "Part Note", systemImage: "note.text") {
                    HeroTextField(
                        label: "Part Note",
                        placeholder: "Chord shapes, reminders…",
                        text: $part.note,
                        axis: .vertical,
                    )
                    .lineLimit(2...)
                }
            }
        }
    }
}

struct StatusChips: View {
    @Binding var status: Part.Status

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Part.Status.allCases) { option in
                Button {
                    status = option
                } label: {
                    HeroChip(title: option.title, isSelected: option == status)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
