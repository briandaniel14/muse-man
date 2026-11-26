import MusicKit
import SwiftUI

extension View {
    func playbackBar(for appleMusicSong: AppleMusicSong?) -> some View {
        modifier(PlaybackBarInset(appleMusicSong: appleMusicSong))
    }
}

struct PlaybackBarInset: ViewModifier {
    let appleMusicSong: AppleMusicSong?
    @State private var keyPress: PlaybackKeyPress?

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if let appleMusicSong {
                    PlaybackBar(appleMusicSong: appleMusicSong, keyPress: keyPress)
                }
            }
            .modifier(PlaybackKeys(isEnabled: appleMusicSong != nil, keyPress: $keyPress))
    }
}

struct PlaybackBar: View {
    let appleMusicSong: AppleMusicSong
    let keyPress: PlaybackKeyPress?
    @State private var content: PlaybackBarContent?
    @State private var song: MusicKit.Song?

    var body: some View {
        ZStack {
            switch content {
            case .fullSong:
                if let song {
                    FullSongBar(song: song, keyPress: keyPress)
                }
            case let .preview(url):
                PreviewBar(url: url, keyPress: keyPress)
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
    let keyPress: PlaybackKeyPress?

    var body: some View {
        PlaybackBarControls(
            audio: .appleMusicSong(song.id),
            isRunning: state.playbackStatus == .playing,
            duration: song.duration ?? 0,
            keyPress: keyPress,
            position: { player.songTime },
            play: play,
            pause: player.pauseSong,
            seek: player.seekSong,
            setSpeed: player.setSongSpeed,
        )
    }

    private func play(at time: TimeInterval, speed: PlaybackSpeed, ownerID: UUID) {
        Task {
            await player.play(song, at: time, speed: speed, ownerID: ownerID)
        }
    }
}
