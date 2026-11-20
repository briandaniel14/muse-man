import SwiftUI

struct RecordSheet: View {
    let onSave: (Data) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var recorder = AudioRecorder()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                TimelineView(.periodic(from: .now, by: 0.25)) { _ in
                    Text(Duration.seconds(recorder.currentTime).formatted(.time(pattern: .minuteSecond)))
                        .font(Theme.largeTitle)
                        .monospacedDigit()
                }
                Button(
                    recorder.isRecording ? "Stop" : "Record",
                    systemImage: recorder.isRecording ? "stop.circle.fill" : "record.circle",
                    action: toggle,
                )
                .labelStyle(.iconOnly)
                .font(.system(size: 72))
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .paperScreen(title: "New Recording")
        }
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
