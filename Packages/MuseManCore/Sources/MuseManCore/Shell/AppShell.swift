import SwiftUI

public struct AppShell: View {
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @State private var selection: Destination = .practiceNext
    @State private var player = AudioPlayer()

    public init() {}

    public var body: some View {
        shell
            .environment(player)
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
            FlatSidebarShell(selection: $selection)
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

#if os(macOS)
    struct FlatSidebarShell: View {
        @Binding var selection: Destination

        var body: some View {
            HStack(spacing: 0) {
                FlatSidebar(selection: $selection)
                VerticalHairline()
                NavigationStack {
                    DestinationScreen(destination: selection)
                }
                .id(selection)
            }
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        }
    }

    struct FlatSidebar: View {
        @Binding var selection: Destination

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Destination.allCases) { destination in
                    FlatSidebarRow(destination: destination, isSelected: destination == selection) {
                        selection = destination
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .frame(width: 240)
            .background(Theme.sidebar)
        }
    }

    struct FlatSidebarRow: View {
        let destination: Destination
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: destination.systemImage)
                        .frame(width: 24)
                    Text(destination.title)
                }
                .font(Theme.body)
                .foregroundStyle(isSelected ? Theme.heading : Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(isSelected ? Theme.selection : Theme.clear, in: .rect(cornerRadius: 8))
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .focusEffectDisabled()
        }
    }
#endif

struct Sidebar: View {
    @Binding var selection: Destination

    var body: some View {
        List(Destination.allCases, selection: Binding($selection)) { destination in
            Label(destination.title, systemImage: destination.systemImage)
                .font(Theme.body)
                .foregroundStyle(Theme.ink)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.sidebar)
        .navigationSplitViewColumnWidth(min: 200, ideal: 240)
    }
}
