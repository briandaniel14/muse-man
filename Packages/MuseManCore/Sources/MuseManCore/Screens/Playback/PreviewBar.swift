import AVFoundation
import SwiftUI

struct PreviewBar: View {
    @Environment(AudioPlayer.self) private var player
    let url: URL
    @State private var source = UUID()
    @State private var time: TimeInterval = 0
    @State private var duration: TimeInterval = 0

    var body: some View {
        PlaybackControls(
            isPlaying: isPlaying,
            time: $time,
            duration: max(duration, 1),
            position: { player.preview == url ? player.previewTime : nil },
            toggle: toggle,
            seek: player.seekPreview,
        )
        .task(id: url) {
            duration = await (try? AVURLAsset(url: url).load(.duration).seconds) ?? 0
        }
        .onChange(of: url) {
            player.stop(from: source)
            time = 0
        }
        .onDisappear {
            player.stop(from: source)
        }
    }

    private var isPlaying: Bool {
        player.preview == url && player.isPreviewPlaying
    }

    private func toggle() {
        if isPlaying {
            player.pausePreview()
        } else {
            player.playPreview(url, at: time, from: source)
        }
    }
}
