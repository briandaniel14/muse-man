import SwiftUI

struct SongFields: View {
    @Binding var title: String
    @Binding var artist: String
    @Binding var key: String?
    @Binding var tempo: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldRow(label: "Title") {
                TextField("Title", text: $title)
            }
            FieldRow(label: "Artist") {
                TextField("Artist", text: $artist)
            }
            FieldRow(label: "Key") {
                TextField("Optional", text: keyText)
            }
            FieldRow(label: "Tempo (BPM)") {
                TextField("Optional", text: tempoText)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
            }
        }
        .textFieldStyle(.plain)
    }

    private var keyText: Binding<String> {
        Binding {
            key ?? ""
        } set: {
            key = $0.isEmpty ? nil : $0
        }
    }

    private var tempoText: Binding<String> {
        Binding {
            tempo.map(String.init) ?? ""
        } set: {
            tempo = Int($0.filter(\.isNumber))
        }
    }
}

struct FieldRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
            content
        }
        .padding(.vertical, 12)
        Hairline()
    }
}
