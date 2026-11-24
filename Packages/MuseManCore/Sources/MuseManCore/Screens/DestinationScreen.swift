import SwiftUI

struct DestinationScreen: View {
    let destination: Destination
    #if os(iOS)
        @State private var isShowingSettings = false
    #endif

    var body: some View {
        screen
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings", systemImage: "gear") {
                    isShowingSettings = true
                }
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsSheet()
        }
        #endif
    }

    @ViewBuilder private var screen: some View {
        switch destination {
        case .practiceNext: PracticeNextScreen()
        case .library: LibraryScreen()
        case .parts: PartsScreen()
        case .collections: CollectionsScreen()
        case .practiceSessions: PracticeSessionsScreen()
        }
    }
}
