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
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.band)
    }
}

struct ArtworkHero<Heading: View, Panel: View, Artwork: View>: View {
    @ViewBuilder let heading: Heading
    @ViewBuilder let panel: Panel
    let artwork: ((CGFloat) -> Artwork)?
    @State private var isWide = true

    var body: some View {
        Hero {
            HeroArtworkLayout {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 24) {
                        heading
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if !isWide, let artwork {
                            shadowed(artwork(Theme.compactHeroArtworkSize))
                        }
                    }
                    panel
                }
                if isWide, let artwork {
                    GeometryReader { geometry in
                        shadowed(artwork(geometry.size.width))
                    }
                }
            }
            .onGeometryChange(for: Bool.self) { geometry in
                geometry.size.width >= Theme.wideHeroWidth
            } action: { isWide in
                self.isWide = isWide
            }
        }
    }

    private func shadowed(_ artwork: Artwork) -> some View {
        artwork
            .shadow(radius: 12, y: 6)
    }
}

extension ArtworkHero where Artwork == SongArtwork {
    init(artworkURL: URL?, @ViewBuilder heading: () -> Heading, @ViewBuilder panel: () -> Panel) {
        self.init(heading: heading, panel: panel, artwork: artworkURL.map { url in
            { size in SongArtwork(url: url, size: size) }
        })
    }
}

struct HeroArtworkLayout: Layout {
    private let spacing: CGFloat = 32

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let artworkSize = artworkSize(width: width, subviews: subviews)
        let detailsHeight = height(of: subviews[0], width: detailsWidth(width, artworkSize: artworkSize))
        return CGSize(width: width, height: max(artworkSize, detailsHeight))
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let artworkSize = artworkSize(width: bounds.width, subviews: subviews)
        subviews[0].place(
            at: bounds.origin,
            proposal: ProposedViewSize(width: detailsWidth(bounds.width, artworkSize: artworkSize), height: nil),
        )
        if subviews.count > 1 {
            subviews[1].place(
                at: CGPoint(x: bounds.maxX - artworkSize, y: bounds.minY),
                proposal: ProposedViewSize(width: artworkSize, height: artworkSize),
            )
        }
    }

    private func artworkSize(width: CGFloat, subviews: Subviews) -> CGFloat {
        guard subviews.count > 1 else { return 0 }
        let largest = min(Theme.maxHeroArtworkSize, width - spacing - Theme.minHeroPanelWidth)
        var size: CGFloat = 0
        for _ in 0 ..< 10 {
            let next = min(largest, height(of: subviews[0], width: detailsWidth(width, artworkSize: size)))
            if abs(next - size) < 1 {
                return next
            }
            size = next
        }
        return size
    }

    private func detailsWidth(_ width: CGFloat, artworkSize: CGFloat) -> CGFloat {
        artworkSize > 0 ? width - spacing - artworkSize : width
    }

    private func height(of subview: LayoutSubview, width: CGFloat) -> CGFloat {
        subview.sizeThatFits(ProposedViewSize(width: width, height: nil)).height
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
