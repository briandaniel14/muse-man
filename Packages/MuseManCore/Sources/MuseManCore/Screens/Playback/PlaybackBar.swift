import MusicKit
import SwiftUI

extension View {
    func playbackBar(for appleMusicSong: AppleMusicSong?) -> some View {
        safeAreaInset(edge: .bottom, spacing: 0) {
            if let appleMusicSong {
                PlaybackBar(appleMusicSong: appleMusicSong)
            }
        }
    }
}

struct PlaybackBar: View {
    let appleMusicSong: AppleMusicSong
    @State private var content: PlaybackBarContent?
    @State private var song: MusicKit.Song?

    var body: some View {
        ZStack {
            switch content {
            case .fullSong:
                if let song {
                    FullSongBar(song: song)
                }
            case nil:
                EmptyView()
            }
        }
        .task(id: appleMusicSong) {
            let canPlay = await SongCatalog.canPlayCatalogContent()
            content = PlaybackBarContent.shown(appleMusicSong: appleMusicSong, canPlayCatalogContent: canPlay)
            song = content == .fullSong ? await SongCatalog.song(appleMusicSong) : nil
        }
    }
}

struct FullSongBar: View {
    @Environment(AudioPlayer.self) private var player
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state
    let song: MusicKit.Song
    @State private var source = UUID()
    @State private var time: TimeInterval = 0
    @State private var isScrubbing = false

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack(spacing: 12) {
                Button(
                    isPlaying ? "Pause" : "Play",
                    systemImage: isPlaying ? "pause.fill" : "play.fill",
                    action: toggle,
                )
                .labelStyle(.iconOnly)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
                PlaybackTime(time: time)
                Slider(value: $time, in: 0 ... duration) { editing in
                    isScrubbing = editing
                    if !editing {
                        player.seekSong(to: time)
                    }
                } label: {
                    Text("Position")
                }
                .labelsHidden()
                .tint(Theme.accent)
                PlaybackTime(time: time - duration)
            }
            .padding(.horizontal, Theme.margin)
            .padding(.vertical, 6)
        }
        .background(Theme.paper)
        .background {
            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                Color.clear
                    .onChange(of: context.date) {
                        if !isScrubbing, player.song == song.id {
                            time = min(player.songTime, duration)
                        }
                    }
            }
        }
        .onChange(of: song.id) {
            player.stop(from: source)
            time = 0
        }
        .onDisappear {
            player.stop(from: source)
        }
    }

    private var duration: TimeInterval {
        max(song.duration ?? 0, 1)
    }

    private var isPlaying: Bool {
        player.song == song.id && state.playbackStatus == .playing
    }

    private func toggle() {
        if isPlaying {
            player.pauseSong()
        } else {
            Task {
                await player.play(song, at: time, from: source)
            }
        }
    }
}

struct PlaybackTime: View {
    let time: TimeInterval

    var body: some View {
        Text((time < 0 ? "-" : "") + Duration.seconds(abs(time).rounded()).formatted(.time(pattern: .minuteSecond)))
            .font(Theme.caption)
            .monospacedDigit()
            .foregroundStyle(Theme.fadedInk)
            .frame(minWidth: 40)
    }
}
