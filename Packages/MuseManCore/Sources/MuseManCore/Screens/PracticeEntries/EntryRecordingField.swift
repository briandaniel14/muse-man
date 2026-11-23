import SwiftUI

struct EntryRecordingField: View {
    @Environment(PracticeLibrary.self) private var library
    let recording: Recording?
    let partID: Part.ID?
    let attach: (Recording?) -> Void
    let onCapture: (Data, Date?) -> Void
    @State private var capture: RecordingCapture?

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
                    capture: $capture,
                    attach: attach,
                )
            }
        }
        .recordingCapture($capture, onCapture: onCapture)
    }
}

struct AttachRecordingMenu: View {
    let recordings: [Recording]
    let isAttached: Bool
    @Binding var capture: RecordingCapture?
    let attach: (Recording?) -> Void

    var body: some View {
        Menu {
            RecordingCaptureButtons(capture: $capture)
            if !recordings.isEmpty {
                Section("The Part's Recordings") {
                    ForEach(recordings) { recording in
                        Button(recording.date.formatted(date: .abbreviated, time: .shortened)) {
                            attach(recording)
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
