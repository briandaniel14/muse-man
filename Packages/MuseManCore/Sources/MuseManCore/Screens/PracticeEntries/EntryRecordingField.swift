import SwiftUI

struct EntryRecordingField: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var recordingID: UUID?
    let partID: Part.ID?
    @State private var isRecording = false
    @State private var isImporting = false

    var body: some View {
        HStack {
            if let recording {
                PlayRecordingButton(recording: recording)
                Text(recording.date.formatted(date: .abbreviated, time: .shortened))
            } else {
                Text("No Recording")
                    .foregroundStyle(Theme.fadedInk)
            }
            Spacer()
            if let partID {
                AttachRecordingMenu(
                    recordings: library.recordings(of: partID),
                    isAttached: recording != nil,
                    isRecording: $isRecording,
                    isImporting: $isImporting,
                ) { identifier in
                    recordingID = identifier
                }
            }
        }
        .sheet(isPresented: $isRecording) {
            RecordSheet { audio in
                if let partID, let recording = try? library.addRecording(audio: audio, to: partID) {
                    recordingID = recording.identifier
                }
            }
        }
        .recordingImporter(isPresented: $isImporting) { audio, date in
            if let partID, let recording = try? library.addRecording(audio: audio, date: date, to: partID) {
                recordingID = recording.identifier
            }
        }
    }

    private var recording: Recording? {
        recordingID.flatMap(library.recording(identifier:))
    }
}

struct AttachRecordingMenu: View {
    let recordings: [Recording]
    let isAttached: Bool
    @Binding var isRecording: Bool
    @Binding var isImporting: Bool
    let attach: (UUID?) -> Void

    var body: some View {
        Menu {
            Button("Record", systemImage: "mic") {
                isRecording = true
            }
            Button("Import Audio…", systemImage: "square.and.arrow.down") {
                isImporting = true
            }
            if !recordings.isEmpty {
                Section("The Part's Recordings") {
                    ForEach(recordings) { recording in
                        Button(recording.date.formatted(date: .abbreviated, time: .shortened)) {
                            attach(recording.identifier)
                        }
                    }
                }
            }
            if isAttached {
                Button("Remove Recording", systemImage: "xmark", role: .destructive) {
                    attach(nil)
                }
            }
        } label: {
            Text(isAttached ? "Change" : "Attach")
                .font(Theme.caption)
                .foregroundStyle(Theme.accent)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }
}
