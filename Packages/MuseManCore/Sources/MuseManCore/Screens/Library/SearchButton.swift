import SwiftUI

struct SearchButton: View {
    let prompt: String
    @Binding var text: String
    @State private var isExpanded = false

    var body: some View {
        if isExpanded {
            field
        } else {
            Button("Search", systemImage: "magnifyingglass") {
                isExpanded = true
            }
        }
    }

    private var field: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.fadedInk)
            TextField(prompt, text: $text)
                .textFieldStyle(.roundedBorder)
            #if os(macOS)
                .onExitCommand(perform: collapse)
            #endif
            Button("Clear", systemImage: "xmark.circle.fill", action: collapse)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.horizontal, 8)
        .frame(width: Theme.searchFieldWidth)
    }

    private func collapse() {
        text = ""
        isExpanded = false
    }
}
