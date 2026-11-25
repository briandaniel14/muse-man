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
                isSongFound: song != nil,
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

    var body: some View {
        PlaybackBarControls(
            audio: .appleMusicSong(song.id),
            isRunning: state.playbackStatus == .playing,
            duration: song.duration ?? 0,
            position: { player.songTime },
            play: play,
            pause: player.pauseSong,
            seek: player.seekSong,
        )
    }

    private func play(at time: TimeInterval, ownerID: UUID) {
        Task {
            await player.play(song, at: time, ownerID: ownerID)
        }
    }
}
