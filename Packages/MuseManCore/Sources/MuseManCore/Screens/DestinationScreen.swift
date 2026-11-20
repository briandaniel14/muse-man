import SwiftUI

struct DestinationScreen: View {
    let destination: Destination

    var body: some View {
        switch destination {
        case .practiceNext: EmptyScreen(destination: .practiceNext)
        case .library: LibraryScreen()
        case .parts: PartsScreen()
        case .collections: EmptyScreen(destination: .collections)
        case .practiceSessions: EmptyScreen(destination: .practiceSessions)
        }
    }
}
