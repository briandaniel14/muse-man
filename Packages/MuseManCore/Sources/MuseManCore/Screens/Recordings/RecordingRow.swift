import SwiftUI

struct RecordingRow: View {
    @Environment(AudioPlayer.self) private var player
    let recording: Recording
    var file: RecordingFile?
    var onDownload: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            PlayRecordingButton(recording: recording)
            if player.nowPlaying?.audio == .recording(recording.id) {
                PlaybackMeter()
                    .padding(.trailing, 10)
            }
            RecordingNameField(recording: recording)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(recording.date.formatted(date: .abbreviated, time: .shortened))
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
                .lineLimit(1)
                .padding(.horizontal, 8)
            if let file {
                ShareLink(item: file, preview: SharePreview(file.fileName)) {
                    Label("Share Recording", systemImage: "square.and.arrow.up")
                }
                .modifier(RecordingRowAction())
            }
            if let onDownload {
                Button("Download Recording", systemImage: "arrow.down", action: onDownload)
                    .modifier(RecordingRowAction())
            }
            if let onDelete {
                Button("Delete Recording", systemImage: "trash", role: .destructive, action: onDelete)
                    .modifier(RecordingRowAction())
            }
        }
        Hairline()
    }
}

struct RecordingNameField: View {
    @Environment(PracticeLibrary.self) private var library
    let recording: Recording
    @State private var name = ""

    var body: some View {
        TextField("Recording name", text: $name, prompt: Text("Untitled").foregroundStyle(Theme.fadedInk))
            .textFieldStyle(.plain)
            .onAppear {
                name = recording.name ?? ""
            }
            .onChange(of: name) {
                if name != (recording.name ?? "") {
                    try? library.renameRecording(id: recording.id, to: name)
                }
            }
    }
}

struct RecordingRowAction: ViewModifier {
    func body(content: Content) -> some View {
        content
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .buttonStyle(.plain)
            .foregroundStyle(Theme.fadedInk)
    }
}

struct PlayRecordingButton: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(AudioPlayer.self) private var player
    let recording: Recording
    @State private var ownerID = UUID()

    var body: some View {
        Button(isPlaying ? "Stop" : "Play", systemImage: isPlaying ? "stop.fill" : "play.fill", action: toggle)
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
            .buttonStyle(.plain)
            .foregroundStyle(Theme.accent)
            .onChange(of: recording.id) {
                player.stop(ownedBy: ownerID)
            }
            .onDisappear {
                player.stop(ownedBy: ownerID)
            }
    }

    private var isPlaying: Bool {
        player.nowPlaying?.audio == .recording(recording.id)
    }

    private func toggle() {
        if isPlaying {
            player.stop()
        } else if let audio = library.audio(of: recording.id) {
            try? player.play(audio, of: recording.id, ownerID: ownerID)
        }
    }
}

struct PlaybackMeter: View {
    @Environment(AudioPlayer.self) private var player
    @State private var levels = Array(repeating: 0.0, count: 10)

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
            HStack(spacing: 2) {
                ForEach(levels.indices, id: \.self) { index in
                    Capsule()
                        .fill(Theme.accent)
                        .frame(width: 3, height: 3 + CGFloat(levels[index]) * 19)
                }
            }
            .frame(height: 22)
            .onChange(of: context.date) {
                levels = Array(levels.dropFirst()) + [player.level()]
            }
        }
        .accessibilityHidden(true)
    }
}
