import SwiftUI

struct KeepAudioPrompt: ViewModifier {
    @Environment(PracticeLibrary.self) private var library
    @Binding var recordings: [Recording]
    let onDecide: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Keep this audio?",
                isPresented: Binding { !recordings.isEmpty } set: {
                    if !$0 {
                        recordings = []
                    }
                },
                titleVisibility: .visible,
                presenting: recordings,
            ) { recordings in
                Button("Keep") {
                    decide(keep: true, of: recordings)
                }
                Button("Discard", role: .destructive) {
                    decide(keep: false, of: recordings)
                }
            } message: { recordings in
                Text(recordings.count == 1
                    ? "It will be lost with the draft if not."
                    : "\(recordings.count) Recordings will be lost with their drafts if not.")
            }
    }

    private func decide(keep: Bool, of recordings: [Recording]) {
        try? library.keepAudio(keep, of: recordings)
        onDecide()
    }
}

extension View {
    func keepAudioPrompt(_ recordings: Binding<[Recording]>, onDecide: @escaping () -> Void = {}) -> some View {
        modifier(KeepAudioPrompt(recordings: recordings, onDecide: onDecide))
    }
}
