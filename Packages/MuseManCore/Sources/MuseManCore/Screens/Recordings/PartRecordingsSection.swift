import SwiftUI

struct PartRecordingsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let part: Part
    @State private var deleting: Recording?
    @State private var capture: RecordingCapture?
    @State private var downloading: RecordingFile?
    @AppStorage("showsPartRecordings") private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleSectionHeader(title: "Recordings", isExpanded: $isExpanded) {
                AddRecordingMenu(capture: $capture)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.accent)
                    .fixedSize()
            }
            if isExpanded {
                let recordings = library.recordings(of: part.id)
                if recordings.isEmpty {
                    Text("No Recordings yet")
                        .foregroundStyle(Theme.fadedInk)
                        .padding(.vertical, 12)
                }
                ForEach(recordings) { recording in
                    RecordingRow(recording: recording, file: file(for: recording)) {
                        downloading = file(for: recording)
                    } onDelete: {
                        deleting = recording
                    }
                }
            }
        }
        .recordingCapture($capture, importsSeveral: true) { audio, date in
            _ = try? library.addRecording(audio: audio, date: date, to: part.id)
        }
        .fileExporter(
            isPresented: Binding { downloading != nil } set: {
                if !$0 {
                    downloading = nil
                }
            },
            item: downloading,
            contentTypes: [.audio],
            defaultFilename: downloading?.fileName,
        ) { _ in }
        .confirmationDialog(
            "Delete Recording?",
            isPresented: Binding { deleting != nil } set: {
                if !$0 {
                    deleting = nil
                }
            },
            titleVisibility: .visible,
            presenting: deleting,
        ) { recording in
            Button("Delete Recording", role: .destructive) {
                try? library.deleteRecording(id: recording.id)
            }
        } message: { _ in
            Text("This can't be undone.")
        }
    }

    private func file(for recording: Recording) -> RecordingFile? {
        library.audio(of: recording.id).map {
            RecordingFile(
                audio: $0,
                name: recording.name,
                partName: "\(part.song.title) \(part.displayName)",
                date: recording.date,
            )
        }
    }
}

struct AddRecordingMenu: View {
    @Binding var capture: RecordingCapture?

    var body: some View {
        Menu("Add Recording", systemImage: "plus") {
            RecordingCaptureButtons(capture: $capture)
        }
        .menuIndicator(.hidden)
    }
}
