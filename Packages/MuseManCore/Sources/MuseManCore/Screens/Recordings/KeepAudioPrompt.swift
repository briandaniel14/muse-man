import SwiftUI

struct KeepAudioPrompt: ViewModifier {
    @Environment(PracticeLibrary.self) private var library
    @Binding var draftAudio: [Recording]
    let onDecide: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Keep this audio?",
                isPresented: Binding { !draftAudio.isEmpty } set: {
                    if !$0 {
                        draftAudio = []
                    }
                },
                titleVisibility: .visible,
                presenting: draftAudio,
            ) { draftAudio in
                Button("Keep", action: onDecide)
                Button("Discard", role: .destructive) {
                    try? library.discardAudio(of: draftAudio)
                    onDecide()
                }
            } message: { draftAudio in
                Text(draftAudio.count == 1
                    ? "It will be lost with the draft if not."
                    : "\(draftAudio.count) Recordings will be lost with their drafts if not.")
            }
    }
}

extension View {
    func keepAudioPrompt(_ draftAudio: Binding<[Recording]>, onDecide: @escaping () -> Void = {}) -> some View {
        modifier(KeepAudioPrompt(draftAudio: draftAudio, onDecide: onDecide))
    }
}
