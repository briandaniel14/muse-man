import AVFoundation
import Observation

@Observable final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private(set) var playing: Recording.ID?
    @ObservationIgnored private var player: AVAudioPlayer?

    func play(_ audio: Data, of recording: Recording.ID) throws {
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
    }

    func level() -> Double {
        guard let player else {
            return 0
        }
        player.updateMeters()
        let decibels = Double(player.averagePower(forChannel: 0))
        return min(max((decibels + 60) / 60, 0), 1)
    }

    func stop() {
        player?.stop()
        player = nil
        playing = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully _: Bool) {
        let finished = ObjectIdentifier(player)
        Task { @MainActor in
            if self.player.map(ObjectIdentifier.init) == finished {
                stop()
            }
        }
    }
}
