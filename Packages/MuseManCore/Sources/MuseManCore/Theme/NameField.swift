import SwiftUI

struct NameField: View {
    let label: String
    let savedName: String?
    let rename: (String) -> Void
    @State private var name = ""

    var body: some View {
        TextField(label, text: $name, prompt: Text("Untitled").foregroundStyle(Theme.fadedInk))
            .textFieldStyle(.plain)
            .onChange(of: savedName, initial: true) {
                if name.trimmedName != savedName {
                    name = savedName ?? ""
                }
            }
            .onChange(of: name) {
                if name.trimmedName != savedName {
                    rename(name)
                }
            }
    }
}
