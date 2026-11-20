import SwiftUI

struct PartsScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var status: Part.Status?
    @State private var instrumentID: Instrument.ID?
    @State private var isManagingInstruments = false

    var body: some View {
        let instruments = library.instruments()
        VStack(spacing: 0) {
            PartsFilter(status: $status, instrumentID: $instrumentID, instruments: instruments)
            Hairline()
            PartList(
                parts: library.parts(status: status, instrument: instrumentID),
                isFiltered: status != nil || instrumentID != nil,
            )
        }
        .onChange(of: instruments) {
            if !instruments.contains(where: { $0.id == instrumentID }) {
                instrumentID = nil
            }
        }
        .navigationDestination(for: Part.self) { part in
            PartScreen(part: part)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Instruments", systemImage: "guitars") {
                    isManagingInstruments = true
                }
            }
        }
        .sheet(isPresented: $isManagingInstruments) {
            InstrumentsSheet()
        }
        .paperScreen(title: Destination.parts.title)
    }
}

struct PartsFilter: View {
    @Binding var status: Part.Status?
    @Binding var instrumentID: Instrument.ID?
    let instruments: [Instrument]

    var body: some View {
        HStack {
            Picker("Status", selection: $status) {
                Text("All Statuses").tag(Part.Status?.none)
                ForEach(Part.Status.allCases) { status in
                    Text(status.title).tag(Optional(status))
                }
            }
            .fixedSize()
            Picker("Instrument", selection: $instrumentID) {
                Text("All Instruments").tag(Instrument.ID?.none)
                ForEach(instruments) { instrument in
                    Text(instrument.name).tag(Optional(instrument.id))
                }
            }
            .fixedSize()
            Spacer()
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 8)
    }
}

struct PartList: View {
    @Environment(\.self) private var environment
    let parts: [Part]
    let isFiltered: Bool

    var body: some View {
        List(parts) { part in
            NavigationLink(value: part) {
                SongPartRow(part: part)
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Theme.hairline.resolve(in: environment))
        }
        .listStyle(.plain)
        .overlay {
            if parts.isEmpty {
                Text(isFiltered ? "No matching Parts" : "No Parts yet")
                    .foregroundStyle(Theme.fadedInk)
            }
        }
    }
}
