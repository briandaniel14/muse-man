import SwiftUI

struct DiscardDraftsButton: View {
    let title: String
    let draftAudio: [Recording]
    let discard: () -> Void
    @State private var draftAudioToDecide: [Recording] = []

    var body: some View {
        Button(title) {
            draftAudioToDecide = draftAudio
            if draftAudioToDecide.isEmpty {
                discard()
            }
        }
        .keepAudioPrompt($draftAudioToDecide, onDecide: discard)
    }
}
