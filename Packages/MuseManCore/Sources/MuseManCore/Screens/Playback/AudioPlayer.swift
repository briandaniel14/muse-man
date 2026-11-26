import AVFoundation
import Combine
import MusicKit
import Observation

@Observable final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    enum Audio: Equatable {
        case recording(Recording.ID)
        case appleMusicSong(MusicItemID)
        case preview(URL)
    }

    struct NowPlaying: Equatable {
        let audio: Audio
        let ownerID: UUID
    }

    private(set) var nowPlaying: NowPlaying?
    private(set) var isPreviewPlaying = false
    @ObservationIgnored private var recordingPlayer: AVAudioPlayer?
    @ObservationIgnored private var previewPlayer: AVPlayer?
    @ObservationIgnored private var previewEnd: NSObjectProtocol?
    @ObservationIgnored private var songDuration: TimeInterval = 0
    @ObservationIgnored private var songStatus: AnyCancellable?

    override init() {
        super.init()
        songStatus = ApplicationMusicPlayer.shared.state.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.rewindSongIfEnded()
                }
            }
    }

    var songTime: TimeInterval {
        let music = ApplicationMusicPlayer.shared
        let time = music.playbackTime
        return isPlayingSong && music.state.playbackStatus != .stopped && !time.isNaN ? time : 0
    }

    var previewTime: TimeInterval {
        let time = previewPlayer?.currentTime().seconds ?? 0
        return time.isFinite ? time : 0
    }

    func play(_ audio: Data, of recording: Recording.ID, ownerID: UUID) throws {
        stop()
        #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        #endif
        let player = try AVAudioPlayer(data: audio)
        player.delegate = self
        player.isMeteringEnabled = true
        player.play()
        recordingPlayer = player
        nowPlaying = NowPlaying(audio: .recording(recording), ownerID: ownerID)
    }

    func play(_ song: MusicKit.Song, at time: TimeInterval, speed: PlaybackSpeed, ownerID: UUID) async {
        let audio = Audio.appleMusicSong(song.id)
        let music = ApplicationMusicPlayer.shared
        if nowPlaying?.audio != audio || music.state.playbackStatus == .stopped {
            stop()
            music.queue = [song]
            songDuration = song.duration ?? 0
            nowPlaying = NowPlaying(audio: audio, ownerID: ownerID)
            try? await music.prepareToPlay()
            music.playbackTime = time
        } else {
            nowPlaying = NowPlaying(audio: audio, ownerID: ownerID)
        }
        try? await music.play()
        if speed != .normal {
            music.state.playbackRate = speed.rate
        }
    }

    func setSongSpeed(_ speed: PlaybackSpeed) {
        let music = ApplicationMusicPlayer.shared
        if isPlayingSong, music.state.playbackStatus == .playing {
            music.state.playbackRate = speed.rate
        }
    }

    func pauseSong() {
        ApplicationMusicPlayer.shared.pause()
    }

    func seekSong(to time: TimeInterval) {
        if isPlayingSong {
            ApplicationMusicPlayer.shared.playbackTime = time
        }
    }

    func playPreview(_ url: URL, at time: TimeInterval, speed: PlaybackSpeed, ownerID: UUID) {
        let audio = Audio.preview(url)
        if nowPlaying?.audio != audio {
            stop()
            #if os(iOS)
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
            #endif
            loadPreview(url)
            seekPreview(to: time)
        }
        nowPlaying = NowPlaying(audio: audio, ownerID: ownerID)
        previewPlayer?.defaultRate = speed.rate
        previewPlayer?.play()
        isPreviewPlaying = true
    }

    func setPreviewSpeed(_ speed: PlaybackSpeed) {
        previewPlayer?.defaultRate = speed.rate
        if isPreviewPlaying {
            previewPlayer?.rate = speed.rate
        }
    }

    func pausePreview() {
        previewPlayer?.pause()
        isPreviewPlaying = false
    }

    func seekPreview(to time: TimeInterval) {
        previewPlayer?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func level() -> Double {
        guard let recordingPlayer else {
            return 0
        }
        recordingPlayer.updateMeters()
        let decibels = Double(recordingPlayer.averagePower(forChannel: 0))
        return min(max((decibels + 60) / 60, 0), 1)
    }

    func stop(ownedBy ownerID: UUID) {
        if nowPlaying?.ownerID == ownerID {
            stop()
        }
    }

    func stop() {
        recordingPlayer?.stop()
        recordingPlayer = nil
        if isPlayingSong {
            ApplicationMusicPlayer.shared.stop()
        }
        previewPlayer?.pause()
        previewPlayer = nil
        previewEnd.map(NotificationCenter.default.removeObserver)
        previewEnd = nil
        isPreviewPlaying = false
        nowPlaying = nil
    }

    private var isPlayingSong: Bool {
        if case .appleMusicSong = nowPlaying?.audio {
            return true
        }
        return false
    }

    private func rewindSongIfEnded() {
        let music = ApplicationMusicPlayer.shared
        if isPlayingSong, songDuration > 0, music.state.playbackStatus == .paused, songTime >= songDuration - 1 {
            music.stop()
        }
    }

    private func loadPreview(_ url: URL) {
        let item = AVPlayerItem(url: url)
        item.audioTimePitchAlgorithm = .spectral
        previewPlayer = AVPlayer(playerItem: item)
        previewEnd = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.didPlayToEndTimeNotification,
            object: item,
            queue: .main,
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.pausePreview()
                self?.seekPreview(to: 0)
            }
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully _: Bool) {
        let finished = ObjectIdentifier(player)
        Task { @MainActor in
            if recordingPlayer.map(ObjectIdentifier.init) == finished {
                stop()
            }
        }
    }
}
