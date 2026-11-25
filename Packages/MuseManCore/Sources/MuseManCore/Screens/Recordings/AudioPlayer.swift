import AVFoundation
import MusicKit
import Observation

@Observable final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var playing: Recording.ID?
    private(set) var song: MusicItemID?
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var startedBy: UUID?
    @ObservationIgnored private var songStartedBy: UUID?

    var songTime: TimeInterval {
        let time = ApplicationMusicPlayer.shared.playbackTime
        return song == nil || time.isNaN ? 0 : time
    }

    func play(_ audio: Data, of recording: Recording.ID, from source: UUID) throws {
        stop()
        #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        #endif
        let player = try AVAudioPlayer(data: audio)
        player.delegate = self
        player.isMeteringEnabled = true
        player.play()
        self.player = player
        playing = recording
        startedBy = source
    }

    func play(_ song: MusicKit.Song, at time: TimeInterval, from source: UUID) async {
        stopRecording()
        let music = ApplicationMusicPlayer.shared
        if self.song != song.id || music.state.playbackStatus == .stopped {
            music.queue = [song]
            self.song = song.id
            try? await music.prepareToPlay()
            music.playbackTime = time
        }
        songStartedBy = source
        try? await music.play()
    }

    func pauseSong() {
        ApplicationMusicPlayer.shared.pause()
    }

    func seekSong(to time: TimeInterval) {
        if song != nil {
            ApplicationMusicPlayer.shared.playbackTime = time
        }
    }

    func level() -> Double {
        guard let player else {
            return 0
        }
        player.updateMeters()
        let decibels = Double(player.averagePower(forChannel: 0))
        return min(max((decibels + 60) / 60, 0), 1)
    }

    func stop(from source: UUID) {
        if startedBy == source || songStartedBy == source {
            stop()
        }
    }

    func stop() {
        stopRecording()
        stopSong()
    }

    private func stopRecording() {
        player?.stop()
        player = nil
        playing = nil
        startedBy = nil
    }

    private func stopSong() {
        if song != nil {
            ApplicationMusicPlayer.shared.stop()
        }
        song = nil
        songStartedBy = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully _: Bool) {
        let finished = ObjectIdentifier(player)
        Task { @MainActor in
            if self.player.map(ObjectIdentifier.init) == finished {
                stopRecording()
            }
        }
    }
}
