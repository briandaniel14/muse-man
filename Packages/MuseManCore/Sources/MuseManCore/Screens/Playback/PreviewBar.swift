import AVFoundation
import SwiftUI

struct PreviewBar: View {
    @Environment(AudioPlayer.self) private var player
    let url: URL
    let keyPress: PlaybackKeyPress?
    @State private var duration: TimeInterval = 0

    var body: some View {
        PlaybackBarControls(
            audio: .preview(url),
            isRunning: player.isPreviewPlaying,
            duration: duration,
            keyPress: keyPress,
            position: { player.previewTime },
            play: { time, speed, ownerID in player.playPreview(url, at: time, speed: speed, ownerID: ownerID) },
            pause: player.pausePreview,
            seek: player.seekPreview,
            setSpeed: player.setPreviewSpeed,
        )
        .task(id: url) {
            duration = await (try? AVURLAsset(url: url).load(.duration).seconds) ?? 0
        }
    }
}
