import SwiftUI

enum RecordingCapture {
    case record
    case importAudio
}

struct RecordingCaptureButtons: View {
    @Binding var capture: RecordingCapture?

    var body: some View {
        Button("Record", systemImage: "mic") {
            capture = .record
        }
        Button("Import Audio…", systemImage: "square.and.arrow.down") {
            capture = .importAudio
        }
    }
}

extension View {
    func recordingCapture(
        _ capture: Binding<RecordingCapture?>,
        importsSeveral: Bool = false,
        onCapture: @escaping (Data, Date?) -> Void,
    ) -> some View {
        sheet(isPresented: capture.is(.record)) {
            RecordSheet { audio in
                onCapture(audio, nil)
            }
        }
        .fileImporter(
            isPresented: capture.is(.importAudio),
            allowedContentTypes: [.audio],
            allowsMultipleSelection: importsSeveral,
        ) { result in
            for url in (try? result.get()) ?? [] {
                let accessing = url.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                if let audio = try? Data(contentsOf: url) {
                    onCapture(audio, try? url.resourceValues(forKeys: [.creationDateKey]).creationDate)
                }
            }
        }
    }
}

private extension Binding<RecordingCapture?> {
    func `is`(_ capture: RecordingCapture) -> Binding<Bool> {
        Binding<Bool> {
            wrappedValue == capture
        } set: { isPresented in
            if !isPresented, wrappedValue == capture {
                wrappedValue = nil
            }
        }
    }
}
