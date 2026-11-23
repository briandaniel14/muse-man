import SwiftUI

struct RecordSheet: View {
    let onSave: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var recorder = AudioRecorder()

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Waveform(levels: recorder.levels, isRecording: recorder.isRecording)
                    .frame(height: 180)
                Text(Duration.seconds(recorder.currentTime).formatted(
                    .time(pattern: .minuteSecond(padMinuteToLength: 2, fractionalSecondsLength: 2)),
                ))
                .font(Theme.largeTitle)
                .monospacedDigit()
                .foregroundStyle(Theme.ink)
                RecordButton(isRecording: recorder.isRecording, action: toggle)
                Text(recorder.isRecording ? "Tap to stop and save" : "Tap to start recording")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            .padding(Theme.margin)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task(id: recorder.isRecording) {
                while recorder.isRecording, !Task.isCancelled {
                    recorder.sampleLevel()
                    try? await Task.sleep(for: .milliseconds(50))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onDisappear {
                recorder.discard()
            }
            .sheetScreen(title: "New Recording")
        }
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 480)
        #endif
    }

    private func toggle() {
        if recorder.isRecording {
            if let audio = try? recorder.stop() {
                onSave(audio)
            }
            dismiss()
        } else {
            Task {
                try? await recorder.start()
            }
        }
    }
}

struct Waveform: View {
    let levels: [Float]
    let isRecording: Bool

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 5
            let playhead = size.width / 2
            let middle = size.height / 2
            let visible = levels.suffix(Int(playhead / step))
            for (offset, level) in visible.reversed().enumerated() {
                let left = playhead - CGFloat(offset + 1) * step
                let height = max(2, CGFloat(level) * size.height * 0.85)
                let bar = CGRect(x: left, y: middle - height / 2, width: 2.5, height: height)
                context.fill(Path(roundedRect: bar, cornerRadius: 1.25), with: .style(Theme.ink))
            }
            var dot = isRecording ? playhead + step : 0
            while dot < size.width {
                context.fill(Path(CGRect(x: dot, y: middle - 0.5, width: 2, height: 1)), with: .style(Theme.hairline))
                dot += step
            }
            if isRecording {
                context.fill(
                    Path(CGRect(x: playhead - 1, y: 0, width: 2, height: size.height)),
                    with: .style(Theme.accent),
                )
                for edge in [0, size.height] {
                    context.fill(
                        Path(ellipseIn: CGRect(x: playhead - 4, y: edge - 4, width: 8, height: 8)),
                        with: .style(Theme.accent),
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .background(Theme.sidebar, in: .rect(cornerRadius: 12))
        .accessibilityHidden(true)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(Theme.hairline, lineWidth: 4)
                RoundedRectangle(cornerRadius: isRecording ? 6 : 29)
                    .fill(.red)
                    .frame(width: isRecording ? 28 : 58, height: isRecording ? 28 : 58)
            }
            .frame(width: 72, height: 72)
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
        .animation(.snappy, value: isRecording)
        .accessibilityLabel(isRecording ? "Stop" : "Record")
    }
}
