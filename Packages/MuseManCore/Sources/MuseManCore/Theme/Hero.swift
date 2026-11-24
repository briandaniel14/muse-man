import SwiftUI

struct Hero<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
        }
        .textFieldStyle(.plain)
        .foregroundStyle(Theme.bandInk)
        .tint(Theme.bandSelection)
        .padding(.horizontal, Theme.margin)
        .padding(.bottom, 32)
        .frame(maxWidth: Theme.readableWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.band)
    }
}

struct ArtworkHero<Heading: View, Panel: View, Artwork: View>: View {
    var panelBesideHeading = false
    @ViewBuilder let heading: Heading
    @ViewBuilder let panel: Panel
    @ViewBuilder let artwork: (CGFloat) -> Artwork
    @State private var isWide = true

    var body: some View {
        Hero {
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: showsPanelBesideHeading ? .top : .center, spacing: 24) {
                        heading
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if showsPanelBesideHeading {
                            panel
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if !isWide {
                            shadowedArtwork(Theme.compactHeroArtworkSize)
                        }
                    }
                    if !showsPanelBesideHeading {
                        panel
                    }
                }
                if isWide {
                    shadowedArtwork(Theme.heroArtworkSize)
                }
            }
            .onGeometryChange(for: Bool.self) { geometry in
                geometry.size.width >= Theme.wideHeroWidth
            } action: { isWide in
                self.isWide = isWide
            }
        }
    }

    private var showsPanelBesideHeading: Bool {
        panelBesideHeading && isWide
    }

    private func shadowedArtwork(_ size: CGFloat) -> some View {
        artwork(size)
            .shadow(radius: 12, y: 6)
    }
}

extension ArtworkHero where Artwork == SongArtwork? {
    init(artworkURL: URL?, @ViewBuilder heading: () -> Heading, @ViewBuilder panel: () -> Panel) {
        self.init(heading: heading, panel: panel) { size in
            artworkURL.map { SongArtwork(url: $0, size: size) }
        }
    }
}

struct HeroTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var axis = Axis.horizontal

    var body: some View {
        TextField(text: $text, prompt: Text(placeholder).foregroundStyle(Theme.bandFadedInk), axis: axis) {
            Text(label)
        }
        .environment(\.colorScheme, .dark)
    }
}

struct HeroChip: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(Theme.caption)
            .foregroundStyle(isSelected ? Theme.band : Theme.highlight)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Theme.highlight : Theme.clear, in: .rect(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Theme.highlight, lineWidth: 1)
            }
    }
}

struct HeroPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.bandPanel, in: .rect(cornerRadius: 12))
    }
}

struct HeroDetail<Content: View>: View {
    let label: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(label)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.bandFadedInk)
                Image(systemName: systemImage)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.highlight)
            }
            content
                .font(Theme.body)
                .foregroundStyle(Theme.bandInk)
        }
    }
}
