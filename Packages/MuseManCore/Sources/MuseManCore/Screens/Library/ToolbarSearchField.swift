import SwiftUI

struct ToolbarSearchField: View {
    let prompt: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.fadedInk)
            TextField(prompt, text: $text)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 8)
        .frame(width: Theme.searchFieldWidth)
    }
}
