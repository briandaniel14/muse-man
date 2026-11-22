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
                TextField("Optional", text: $key.orEmpty)
            }
            FieldRow(label: "Tempo (BPM)") {
                TextField("Optional", text: $tempo.digits)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
            }
        }
        .textFieldStyle(.plain)
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

extension Binding<String?> {
    var orEmpty: Binding<String> {
        Binding<String> {
            wrappedValue ?? ""
        } set: {
            wrappedValue = $0.isEmpty ? nil : $0
        }
    }
}

extension Binding<Int?> {
    var digits: Binding<String> {
        Binding<String> {
            wrappedValue.map(String.init) ?? ""
        } set: {
            wrappedValue = Int($0.filter(\.isNumber))
        }
    }
}
