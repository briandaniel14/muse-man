import SwiftUI

struct ResourceSheet: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    let songID: Song.ID
    let resource: Resource?
    @State private var link: String
    @State private var title: String

    init(songID: Song.ID, resource: Resource? = nil) {
        self.songID = songID
        self.resource = resource
        _link = State(initialValue: resource?.url.absoluteString ?? "")
        _title = State(initialValue: resource?.title ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FieldRow(label: "Link") {
                        TextField("https://", text: $link)
                            .autocorrectionDisabled()
                        #if os(iOS)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                        #endif
                    }
                    FieldRow(label: "Title") {
                        TextField("Optional", text: $title)
                    }
                }
                .textFieldStyle(.plain)
                .padding(.horizontal, Theme.margin)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(resource == nil ? "Add" : "Save") {
                        save()
                        dismiss()
                    }
                    .disabled(url == nil)
                }
            }
            .sheetScreen(title: resource == nil ? "New Resource" : "Edit Resource")
        }
    }

    private var url: URL? {
        let text = link.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, !text.contains(" ") else {
            return nil
        }
        return URL(string: text.contains("://") ? text : "https://\(text)")
    }

    private func save() {
        guard let url else {
            return
        }
        if var resource {
            resource.url = url
            resource.title = title
            try? library.updateResource(resource)
        } else {
            _ = try? library.addResource(url: url, title: title, to: songID)
        }
    }
}
