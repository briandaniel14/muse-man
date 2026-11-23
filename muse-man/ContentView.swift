import MuseManCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        AppShell()
    }
}

#Preview {
    ContentView()
        .environment(PracticeLibrary(container: PersistentStore.container()))
}
