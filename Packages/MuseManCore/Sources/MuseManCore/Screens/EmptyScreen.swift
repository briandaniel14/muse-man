import SwiftUI

struct EmptyScreen: View {
    let destination: Destination

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: destination.systemImage)
                .font(.largeTitle)
                .foregroundStyle(Theme.accent)
            Text("Nothing here yet")
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(Theme.margin)
        .paperScreen(title: destination.title)
    }
}
