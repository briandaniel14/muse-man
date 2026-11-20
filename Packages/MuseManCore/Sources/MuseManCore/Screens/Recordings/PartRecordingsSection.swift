import SwiftUI

struct PartRecordingsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let partID: Part.ID
    @State private var player = AudioPlayer()
    @State private var isRecording = false
    @State private var isImporting = false
    @State private var deleting: Recording?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recordings")
                    .font(Theme.title)
                Spacer()
                AddRecordingMenu(isRecording: $isRecording, isImporting: $isImporting)
            }
            .padding(.bottom, 4)
            Hairline()
            let recordings = library.recordings(of: partID)
            if recordings.isEmpty {
                Text("No Recordings yet")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(recordings) { recording in
                RecordingRow(recording: recording, player: player) {
                    deleting = recording
                }
            }
        }
        .sheet(isPresented: $isRecording) {
            RecordSheet { audio in
                _ = try? library.addRecording(audio: audio, to: partID)
            }
        }
        .recordingImporter(isPresented: $isImporting) { audio, date in
            _ = try? library.addRecording(audio: audio, date: date, to: partID)
        }
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
                if player.playing == recording.id {
                    player.stop()
                }
                try? library.deleteRecording(id: recording.id)
            }
        } message: { _ in
            Text("This can't be undone.")
        }
        .onDisappear {
            player.stop()
        }
    }
}

struct AddRecordingMenu: View {
    @Binding var isRecording: Bool
    @Binding var isImporting: Bool

    var body: some View {
        Menu {
            Button("Record", systemImage: "mic") {
                isRecording = true
            }
            Button("Import Audio…", systemImage: "square.and.arrow.down") {
                isImporting = true
            }
        } label: {
            Label("Add Recording", systemImage: "plus")
                .labelStyle(.iconOnly)
                .foregroundStyle(Theme.accent)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
    }
}
