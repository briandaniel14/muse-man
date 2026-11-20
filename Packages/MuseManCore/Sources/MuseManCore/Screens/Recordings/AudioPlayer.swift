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
        player.play()
        self.player = player
        playing = recording
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
