import SwiftUI

struct PaperScreen: ViewModifier {
    enum Kind {
        case paper
        case sheet
        case hero
    }

    let title: String
    let kind: Kind
    var isFullWidth = false

    private var hasHero: Bool {
        kind == .hero
    }

    func body(content: Content) -> some View {
        content
            .font(Theme.body)
            .foregroundStyle(Theme.ink)
            .scrollContentBackground(.hidden)
            .modifier(PageHeading(title: title, isVisible: kind == .sheet))
            .frame(maxWidth: hasHero || isFullWidth ? .infinity : Theme.readableWidth)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .modifier(TitleBand(title: title, isVisible: kind == .paper))
            .background {
                PaperBackground(hasHero: hasHero)
            }
            .toolbarTitleDisplayMode(.inline)
        #if os(macOS)
            .navigationTitle(hasHero ? title : "")
            .toolbar(removing: .title)
            .toolbar {
                ToolbarSpacer(.flexible)
            }
        #else
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if !hasHero {
                        Text(title)
                            .font(Theme.title)
                            .foregroundStyle(Theme.heading)
                    }
                }
            }
        #endif
    }
}

struct PaperBackground: View {
    let hasHero: Bool

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Theme.paper)
            if hasHero {
                Rectangle()
                    .fill(Theme.band)
                    .frame(height: 240)
            }
        }
        .ignoresSafeArea()
    }
}

struct PageHeading: ViewModifier {
    let title: String
    let isVisible: Bool

    func body(content: Content) -> some View {
        #if os(macOS)
            content.safeAreaInset(edge: .top, spacing: 0) {
                if isVisible {
                    Text(title)
                        .font(Theme.largeTitle)
                        .foregroundStyle(Theme.heading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Theme.margin)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .background(Theme.paper)
                }
            }
        #else
            content
        #endif
    }
}

struct TitleBand: ViewModifier {
    let title: String
    let isVisible: Bool

    func body(content: Content) -> some View {
        #if os(macOS)
            content.overlay(alignment: .top) {
                if isVisible {
                    GeometryReader { proxy in
                        Text(title)
                            .font(Theme.title)
                            .foregroundStyle(Theme.bandInk)
                            .padding(.horizontal, Theme.margin)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: proxy.safeAreaInsets.top)
                            .background(Theme.band)
                            .offset(y: -proxy.safeAreaInsets.top)
                    }
                    .allowsHitTesting(false)
                }
            }
        #else
            content
        #endif
    }
}

struct PaperRow: ViewModifier {
    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        content
            .font(Theme.body)
            .foregroundStyle(Theme.ink)
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Theme.hairline.resolve(in: environment))
        #if os(macOS)
            .padding(.vertical, 6)
            .listRowInsets(EdgeInsets(top: 0, leading: Theme.margin, bottom: 0, trailing: Theme.margin))
        #endif
    }
}

public extension View {
    func paperScreen(title: String, isFullWidth: Bool = false) -> some View {
        modifier(PaperScreen(title: title, kind: .paper, isFullWidth: isFullWidth))
    }

    func sheetScreen(title: String) -> some View {
        modifier(PaperScreen(title: title, kind: .sheet))
        #if os(macOS)
            .toolbar(.hidden, for: .windowToolbar)
        #endif
    }

    func heroScreen(title: String) -> some View {
        modifier(PaperScreen(title: title, kind: .hero))
    }

    func paperRow() -> some View {
        modifier(PaperRow())
    }
}
