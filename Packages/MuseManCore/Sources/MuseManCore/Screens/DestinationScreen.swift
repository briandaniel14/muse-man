import SwiftUI

struct DestinationScreen: View {
    let destination: Destination

    var body: some View {
        switch destination {
        case .practiceNext: PracticeNextScreen()
        case .library: LibraryScreen()
        case .parts: EmptyScreen(destination: .parts)
        case .collections: EmptyScreen(destination: .collections)
        case .practiceSessions: EmptyScreen(destination: .practiceSessions)
        }
    }
}
