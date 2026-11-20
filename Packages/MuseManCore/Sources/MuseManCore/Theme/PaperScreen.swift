import SwiftUI

struct PaperScreen: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .font(Theme.body)
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inline)
        #if os(macOS)
            .toolbar(removing: .title)
        #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(Theme.title)
                        .foregroundStyle(Theme.ink)
                }
            }
    }
}

public extension View {
    func paperScreen(title: String) -> some View {
        modifier(PaperScreen(title: title))
    }
}
