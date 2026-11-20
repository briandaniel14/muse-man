import SwiftUI

public struct AppShell: View {
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @State private var selection: Destination = .practiceNext

    public init() {}

    public var body: some View {
        shell
            .tint(Theme.accent)
    }

    @ViewBuilder private var shell: some View {
        #if os(iOS)
            if horizontalSizeClass == .compact {
                TabShell(selection: $selection)
            } else {
                SidebarShell(selection: $selection)
            }
        #else
            SidebarShell(selection: $selection)
        #endif
    }
}

struct TabShell: View {
    @Binding var selection: Destination

    var body: some View {
        TabView(selection: $selection) {
            ForEach(Destination.allCases) { destination in
                Tab(destination.title, systemImage: destination.systemImage, value: destination) {
                    NavigationStack {
                        DestinationScreen(destination: destination)
                    }
                }
            }
        }
    }
}

struct SidebarShell: View {
    @Binding var selection: Destination
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(selection: $selection)
        } detail: {
            NavigationStack {
                DestinationScreen(destination: selection)
            }
            .id(selection)
        }
    }
}

struct Sidebar: View {
    @Binding var selection: Destination

    var body: some View {
        List(Destination.allCases, selection: Binding($selection)) { destination in
            Label(destination.title, systemImage: destination.systemImage)
                .font(Theme.body)
                .foregroundStyle(Theme.ink)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.paper)
        .navigationSplitViewColumnWidth(min: 200, ideal: 240)
    }
}
