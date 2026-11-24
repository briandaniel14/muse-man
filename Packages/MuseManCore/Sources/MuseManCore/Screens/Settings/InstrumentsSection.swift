import SwiftUI

struct InstrumentsSection: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var renaming: Instrument?
    @State private var newName = ""
    @State private var blocked: BlockedDeletion?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitle("Instruments")
            let instruments = library.instruments()
            if instruments.isEmpty {
                Text("No Instruments yet. Add one when you add a Part to a Song.")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(instruments) { instrument in
                InstrumentRow(
                    instrument: instrument,
                    partCount: library.parts(instrument: instrument.id).count,
                ) {
                    newName = instrument.name
                    renaming = instrument
                } onDelete: {
                    delete(instrument)
                }
            }
        }
        .alert("Rename Instrument", isPresented: isPresented($renaming), presenting: renaming) { instrument in
            TextField("Name", text: $newName)
            Button("Cancel", role: .cancel) {}
            Button("Rename") {
                rename(instrument)
            }
            .disabled(trimmedName.isEmpty)
        }
        .alert(
            "Can't Delete \(blocked?.name ?? "Instrument")",
            isPresented: isPresented($blocked),
            presenting: blocked,
        ) { _ in
            Button("OK") {}
        } message: { blocked in
            Text("^[\(blocked.partCount) Part](inflect: true) still use it. Delete those Parts first.")
        }
    }

    private var trimmedName: String {
        newName.trimmingCharacters(in: .whitespaces)
    }

    private func rename(_ instrument: Instrument) {
        var instrument = instrument
        instrument.name = trimmedName
        try? library.updateInstrument(instrument)
    }

    private func delete(_ instrument: Instrument) {
        do {
            try library.deleteInstrument(id: instrument.id)
        } catch {
            blocked = (error as? InstrumentInUseError).map {
                BlockedDeletion(name: instrument.name, partCount: $0.partCount)
            }
        }
    }

    private func isPresented(_ item: Binding<(some Any)?>) -> Binding<Bool> {
        Binding {
            item.wrappedValue != nil
        } set: { isPresented in
            if !isPresented {
                item.wrappedValue = nil
            }
        }
    }
}

struct BlockedDeletion {
    let name: String
    let partCount: Int
}

struct InstrumentRow: View {
    let instrument: Instrument
    let partCount: Int
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(instrument.name)
                    .foregroundStyle(Theme.ink)
                Text(partsText)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Menu {
                Button("Rename", systemImage: "pencil", action: onRename)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Label("Options", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Theme.fadedInk)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
        }
        .padding(.vertical, 4)
        Hairline()
    }

    private var partsText: LocalizedStringKey {
        partCount == 0 ? "No Parts" : "^[\(partCount) Part](inflect: true)"
    }
}
