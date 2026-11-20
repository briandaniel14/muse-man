import SwiftUI

struct PracticeNextScreen: View {
    @Environment(PracticeLibrary.self) private var library

    var body: some View {
        DuePartList(parts: library.practiceNext())
            .navigationDestination(for: Part.self) { part in
                PartScreen(part: part)
            }
            .paperScreen(title: Destination.practiceNext.title)
    }
}

struct DuePartList: View {
    @Environment(\.self) private var environment
    let parts: [Part]

    var body: some View {
        List(parts) { part in
            NavigationLink(value: part) {
                DuePartRow(part: part)
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Theme.hairline.resolve(in: environment))
        }
        .listStyle(.plain)
        .overlay {
            if parts.isEmpty {
                Text("Nothing Due today")
                    .foregroundStyle(Theme.fadedInk)
            }
        }
    }
}
