import AVFoundation
import SwiftUI

struct PreviewBar: View {
    @Environment(AudioPlayer.self) private var player
    let url: URL
    @State private var duration: TimeInterval = 0

    var body: some View {
        PlaybackBarControls(
            audio: .preview(url),
            isRunning: player.isPreviewPlaying,
            duration: duration,
            position: { player.previewTime },
            play: { time, ownerID in player.playPreview(url, at: time, ownerID: ownerID) },
            pause: player.pausePreview,
            seek: player.seekPreview,
        )
        .task(id: url) {
            duration = await (try? AVURLAsset(url: url).load(.duration).seconds) ?? 0
        }
    }
}
