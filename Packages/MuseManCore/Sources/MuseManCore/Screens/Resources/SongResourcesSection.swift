import SwiftUI

struct SongResourcesSection: View {
    @Environment(PracticeLibrary.self) private var library
    let songID: Song.ID
    @State private var isAdding = false
    @State private var editing: Resource?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Resources")
                    .font(Theme.title)
                Spacer()
                Button("Add Resource", systemImage: "plus") {
                    isAdding = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
            }
            .padding(.bottom, 4)
            Hairline()
            let resources = library.resources(for: songID)
            if resources.isEmpty {
                Text("No Resources yet")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            ForEach(resources) { resource in
                ResourceRow(resource: resource) {
                    editing = resource
                } onDelete: {
                    try? library.deleteResource(id: resource.id)
                }
            }
        }
        .sheet(isPresented: $isAdding) {
            ResourceSheet(songID: songID)
        }
        .sheet(item: $editing) { resource in
            ResourceSheet(songID: songID, resource: resource)
        }
    }
}

struct ResourceRow: View {
    let resource: Resource
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Link(destination: resource.url) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(resource.name)
                        .foregroundStyle(Theme.ink)
                    Text(resource.url.absoluteString)
                        .font(Theme.caption)
                        .foregroundStyle(Theme.fadedInk)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            Menu {
                Button("Edit", systemImage: "pencil", action: onEdit)
                Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Label("Options", systemImage: "ellipsis")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Theme.fadedInk)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
        }
        .padding(.vertical, 4)
        Hairline()
    }
}
