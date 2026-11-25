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
            case let .preview(url):
                PreviewBar(url: url)
            case nil:
                EmptyView()
            }
        }
        .task(id: appleMusicSong) {
            let canPlay = await SongCatalog.canPlayCatalogContent()
            let song = await SongCatalog.song(appleMusicSong)
            content = PlaybackBarContent.shown(
                appleMusicSong: appleMusicSong,
                canPlayCatalogContent: canPlay,
                previewURL: song?.previewAssets?.first?.url,
            )
            self.song = song
        }
    }
}

struct FullSongBar: View {
    @Environment(AudioPlayer.self) private var player
    @ObservedObject private var state = ApplicationMusicPlayer.shared.state
    let song: MusicKit.Song
    @State private var source = UUID()
    @State private var time: TimeInterval = 0

    var body: some View {
        PlaybackControls(
            isPlaying: isPlaying,
            time: $time,
            duration: duration,
            position: { player.song == song.id ? player.songTime : nil },
            toggle: toggle,
            seek: player.seekSong,
        )
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
