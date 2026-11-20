import SwiftUI

struct AddPartSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    let song: Song
    @State private var instrumentID: Instrument.ID?
    @State private var newInstrumentName = ""
    @State private var label = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
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
            .paperScreen(title: "New Part")
        }
    }

    private var isIncomplete: Bool {
        instrumentID == nil && trimmed(newInstrumentName) == nil
    }

    private func add() {
        guard let instrumentID = instrumentID ?? addNewInstrument() else {
            return
        }
        _ = try? library.addPart(to: song.id, instrument: instrumentID, label: trimmed(label))
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
