import SwiftUI

struct PlaybackBarControls: View {
    @Environment(AudioPlayer.self) private var player
    @SkipIntervalSetting private var skipInterval
    let audio: AudioPlayer.Audio
    let isRunning: Bool
    let duration: TimeInterval
    let keyPress: PlaybackKeyPress?
    let position: () -> TimeInterval
    let play: (TimeInterval, PlaybackSpeed, UUID) -> Void
    let pause: () -> Void
    let seek: (TimeInterval) -> Void
    let setSpeed: (PlaybackSpeed) -> Void
    @State private var ownerID = UUID()
    @State private var time: TimeInterval = 0
    @State private var speed = PlaybackSpeed.normal

    var body: some View {
        PlaybackControls(
            isPlaying: isPlaying,
            time: $time,
            duration: max(duration, 1),
            speed: $speed,
            position: { isCurrent ? position() : nil },
            toggle: toggle,
            seek: seek,
        )
        .onChange(of: audio) {
            player.stop(ownedBy: ownerID)
            time = 0
            speed = .normal
        }
        .onChange(of: speed) {
            if isCurrent {
                setSpeed(speed)
            }
        }
        .onChange(of: keyPress) {
            switch keyPress?.key {
            case .playPause:
                toggle()
            case let .skip(direction):
                skip(direction)
            case nil:
                break
            }
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
            play(time, speed, ownerID)
        }
    }

    private func skip(_ direction: Skip) {
        time = direction.time(from: isCurrent ? position() : time, by: skipInterval, duration: duration)
        if isCurrent {
            seek(time)
        }
    }
}
