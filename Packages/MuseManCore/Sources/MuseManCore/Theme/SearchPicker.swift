import SwiftUI

struct SearchPicker<Item: Identifiable, Label: View>: View {
    let prompt: String
    let emptyText: String
    let items: (String) -> [Item]
    let choose: (Item) -> Void
    @ViewBuilder let label: (Item) -> Label
    @State private var search = ""

    var body: some View {
        let results = items(search)
        VStack(spacing: 0) {
            SearchField(prompt: prompt, text: $search)
                .padding(12)
            Hairline()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(results) { item in
                        Button {
                            choose(item)
                        } label: {
                            HStack {
                                label(item)
                                Spacer()
                                Image(systemName: "plus")
                                    .foregroundStyle(Theme.accent)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        Hairline()
                            .padding(.leading, 16)
                    }
                }
            }
            .overlay {
                if results.isEmpty {
                    Text(search.isEmpty ? emptyText : "No matches")
                        .foregroundStyle(Theme.fadedInk)
                }
            }
        }
        .font(Theme.body)
        .foregroundStyle(Theme.ink)
        #if os(macOS)
            .frame(width: 380, height: 440)
        #endif
            .background(Theme.paper)
    }
}

struct SearchField: View {
    let prompt: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.fadedInk)
            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Theme.sidebar, in: .rect(cornerRadius: 8))
    }
}

struct AddPopoverButton<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    @State private var isPresented = false

    var body: some View {
        Button(title, systemImage: "plus") {
            isPresented = true
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .foregroundStyle(Theme.accent)
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            content
        }
    }
}

struct PartPickerButton: View {
    @Environment(PracticeLibrary.self) private var library
    var excluding: Set<Part.ID> = []
    let choose: (Part) -> Void

    var body: some View {
        AddPopoverButton(title: "Add Part") {
            SearchPicker(
                prompt: "Song, artist or instrument",
                emptyText: "No Parts to add",
                items: { library.parts(matching: $0).filter { !excluding.contains($0.id) } },
                choose: choose,
                label: { part in
                    PartTitle(part: part)
                },
            )
        }
    }
}
