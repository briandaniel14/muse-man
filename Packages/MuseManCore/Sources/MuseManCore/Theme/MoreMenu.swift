import SwiftUI

struct MoreMenu<Content: View>: ToolbarContent {
    var isOnHero = true
    var placement = ToolbarItemPlacement.primaryAction
    @ViewBuilder let content: Content

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Menu {
                content
            } label: {
                Label("More", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(isOnHero ? Theme.bandInk : Theme.heading)
            }
            .menuIndicator(.hidden)
            .menuStyle(.button)
            .buttonStyle(.plain)
        }
        .sharedBackgroundVisibility(.hidden)
    }
}
