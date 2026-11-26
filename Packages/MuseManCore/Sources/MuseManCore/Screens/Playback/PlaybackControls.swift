import SwiftUI

struct PlaybackControls: View {
    let isPlaying: Bool
    @Binding var time: TimeInterval
    let duration: TimeInterval
    @Binding var speed: PlaybackSpeed
    let position: () -> TimeInterval?
    let toggle: () -> Void
    let seek: (TimeInterval) -> Void
    @State private var isScrubbing = false

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack(spacing: 12) {
                Button(
                    isPlaying ? "Pause" : "Play",
                    systemImage: isPlaying ? "pause.fill" : "play.fill",
                    action: toggle,
                )
                .labelStyle(.iconOnly)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(.rect)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
                PlaybackTime(time: time)
                Slider(value: $time, in: 0 ... duration) { editing in
                    isScrubbing = editing
                    if !editing {
                        seek(time)
                    }
                } label: {
                    Text("Position")
                }
                .labelsHidden()
                .tint(Theme.accent)
                PlaybackTime(time: time - duration)
                if showsSpeedMenu {
                    SpeedMenu(speed: $speed)
                }
            }
            .padding(.horizontal, Theme.margin)
            .padding(.vertical, 6)
        }
        .background(Theme.paper)
        .background {
            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                Color.clear
                    .onChange(of: context.date) {
                        if !isScrubbing, let position = position() {
                            time = min(position, duration)
                        }
                    }
            }
        }
    }

    private var showsSpeedMenu: Bool {
        #if os(iOS)
            UIDevice.current.userInterfaceIdiom != .phone
        #else
            true
        #endif
    }
}

struct PlaybackTime: View {
    let time: TimeInterval

    var body: some View {
        Text((time < 0 ? "-" : "") + Duration.seconds(abs(time).rounded()).formatted(.time(pattern: .minuteSecond)))
            .font(Theme.caption)
            .monospacedDigit()
            .foregroundStyle(Theme.fadedInk)
            .frame(minWidth: 40)
    }
}
