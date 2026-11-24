import MuseManCore
import SwiftUI

@main struct MyApp: App {
    @State private var library = PracticeLibrary(container: PersistentStore.app())

    init() {
        Fonts.register()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(library)
        }
        #if os(macOS)
            Settings {
                SettingsScreen()
                    .environment(library)
            }
        #endif
    }
}
