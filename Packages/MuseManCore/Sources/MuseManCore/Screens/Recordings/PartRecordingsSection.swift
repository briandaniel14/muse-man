import SwiftUI

struct PartRecordingsSection: View {
    @Environment(PracticeLibrary.self) private var library
    let partID: Part.ID
    @State private var player = AudioPlayer()
    @State private var deleting: Recording?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recordings")
                .font(Theme.title)
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
        Menu("Add Recording", systemImage: "plus") {
            Button("Record", systemImage: "mic") {
                isRecording = true
            }
            Button("Import Audio…", systemImage: "square.and.arrow.down") {
                isImporting = true
            }
        }
        .menuIndicator(.hidden)
    }
}
