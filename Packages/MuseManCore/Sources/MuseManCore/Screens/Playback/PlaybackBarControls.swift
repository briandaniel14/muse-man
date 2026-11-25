import SwiftUI

struct PlaybackBarControls: View {
    @Environment(AudioPlayer.self) private var player
    let audio: AudioPlayer.Audio
    let isRunning: Bool
    let duration: TimeInterval
    let position: () -> TimeInterval
    let play: (TimeInterval, UUID) -> Void
    let pause: () -> Void
    let seek: (TimeInterval) -> Void
    @State private var ownerID = UUID()
    @State private var time: TimeInterval = 0

    var body: some View {
        PlaybackControls(
            isPlaying: isPlaying,
            time: $time,
            duration: max(duration, 1),
            position: { isCurrent ? position() : nil },
            toggle: toggle,
            seek: seek,
        )
        .onChange(of: audio) {
            player.stop(ownedBy: ownerID)
            time = 0
        }
        .onDisappear {
            player.stop(ownedBy: ownerID)
        }
    }

    private var isCurrent: Bool {
        player.nowPlaying?.audio == audio
    }

    private var isPlaying: Bool {
        isCurrent && isRunning
    }

    private func toggle() {
        if isPlaying {
            pause()
        } else {
            play(time, ownerID)
        }
    }
}
