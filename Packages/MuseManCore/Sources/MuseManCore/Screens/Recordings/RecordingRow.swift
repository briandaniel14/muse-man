import SwiftUI

struct RecordingRow: View {
    @Environment(PracticeLibrary.self) private var library
    let recording: Recording
    let player: AudioPlayer
    var onDelete: (() -> Void)?

    var body: some View {
        HStack {
            Button(isPlaying ? "Stop" : "Play", systemImage: isPlaying ? "stop.fill" : "play.fill", action: toggle)
                .labelStyle(.iconOnly)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
            Text(recording.date.formatted(date: .abbreviated, time: .shortened))
                .frame(maxWidth: .infinity, alignment: .leading)
            if let onDelete {
                Button("Delete Recording", systemImage: "trash", role: .destructive, action: onDelete)
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(.rect)
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.fadedInk)
            }
        }
        Hairline()
    }

    private var isPlaying: Bool {
        player.playing == recording.id
    }

    private func toggle() {
        if isPlaying {
            player.stop()
        } else if let audio = library.audio(of: recording.id) {
            try? player.play(audio, of: recording.id)
        }
    }
}
