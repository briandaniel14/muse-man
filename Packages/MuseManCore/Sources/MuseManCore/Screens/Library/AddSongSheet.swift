import SwiftUI

struct AddSongSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var artist = ""
    @State private var key: String?
    @State private var tempo: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                SongFields(title: $title, artist: $artist, key: $key, tempo: $tempo)
                    .padding(.horizontal, Theme.margin)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        _ = try? library.addSong(title: title, artist: artist, key: key, tempo: tempo)
                        dismiss()
                    }
                    .disabled(isIncomplete)
                }
            }
            .paperScreen(title: "New Song")
        }
    }

    private var isIncomplete: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty || artist.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
