import SwiftUI

struct AddPartSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State private var songID: Song.ID?
    private let fixedSong: Song?
    @State private var instrumentID: Instrument.ID?
    @State private var newInstrumentName = ""
    @State private var label = ""

    init(song: Song? = nil) {
        fixedSong = song
        _songID = State(initialValue: song?.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FieldRow(label: "Song") {
                        if let fixedSong {
                            Text(fixedSong.title)
                        } else {
                            SongPicker(songs: library.songs(matching: ""), selection: $songID)
                        }
                    }
                    FieldRow(label: "Instrument") {
                        InstrumentPicker(instruments: library.instruments(), selection: $instrumentID)
                    }
                    if instrumentID == nil {
                        FieldRow(label: "New Instrument") {
                            TextField("Name, such as Guitar", text: $newInstrumentName)
                        }
                    }
                    FieldRow(label: "Label") {
                        TextField("Optional, such as Lead or Drop D", text: $label)
                    }
                }
                .textFieldStyle(.plain)
                .padding(.horizontal, Theme.margin)
            }
            .onAppear {
                instrumentID = library.instruments().first?.id
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add()
                        dismiss()
                    }
                    .disabled(isIncomplete)
                }
            }
            .sheetScreen(title: "New Part")
        }
    }

    private var isIncomplete: Bool {
        songID == nil || (instrumentID == nil && trimmed(newInstrumentName) == nil)
    }

    private func add() {
        guard let songID, let instrumentID = instrumentID ?? addNewInstrument() else {
            return
        }
        _ = try? library.addPart(to: songID, instrument: instrumentID, label: trimmed(label))
    }

    private func addNewInstrument() -> Instrument.ID? {
        trimmed(newInstrumentName).flatMap { try? library.addInstrument(name: $0).id }
    }

    private func trimmed(_ text: String) -> String? {
        let text = text.trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : text
    }
}

struct InstrumentPicker: View {
    let instruments: [Instrument]
    @Binding var selection: Instrument.ID?

    var body: some View {
        Picker("Instrument", selection: $selection) {
            ForEach(instruments) { instrument in
                Text(instrument.name).tag(Optional(instrument.id))
            }
            Text("New Instrument…").tag(Instrument.ID?.none)
        }
        .labelsHidden()
        .fixedSize()
    }
}

struct SongPicker: View {
    let songs: [Song]
    @Binding var selection: Song.ID?

    var body: some View {
        Picker("Song", selection: $selection) {
            Text("Choose a Song").tag(Song.ID?.none)
            ForEach(songs) { song in
                Text("\(song.title) · \(song.artist)").tag(Optional(song.id))
            }
        }
        .labelsHidden()
        .fixedSize()
    }
}
