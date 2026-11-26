import SwiftUI

struct AppleMusicBadge: View {
    let song: AppleMusicSong

    var body: some View {
        Link(destination: song.url) {
            Image("ListenOnAppleMusic", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Listen on Apple Music")
    }
}

struct AppleMusicBadgeRow<Details: View>: View {
    let song: AppleMusicSong?
    @ViewBuilder let details: Details

    var body: some View {
        if let song {
            BesideOrBelowLayout(
                besideSpacing: Theme.badgeBesideDetailsSpacing,
                belowSpacing: Theme.badgeBelowDetailsSpacing,
            ) {
                details
                AppleMusicBadge(song: song)
            }
        } else {
            details
        }
    }
}

struct BesideOrBelowLayout: Layout {
    let besideSpacing: CGFloat
    let belowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        if fitsBeside(sizes, in: proposal.width) {
            return CGSize(width: besideWidth(sizes), height: sizes.map(\.height).max() ?? 0)
        }
        let height = sizes.map(\.height).reduce(0, +) + belowSpacing * CGFloat(max(0, sizes.count - 1))
        return CGSize(width: sizes.map(\.width).max() ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let isBeside = fitsBeside(sizes, in: proposal.width)
        var point = bounds.origin
        for (subview, size) in zip(subviews, sizes) {
            if isBeside {
                subview.place(
                    at: CGPoint(x: point.x, y: bounds.midY),
                    anchor: .leading,
                    proposal: ProposedViewSize(size),
                )
                point.x += size.width + besideSpacing
            } else {
                subview.place(at: point, proposal: ProposedViewSize(size))
                point.y += size.height + belowSpacing
            }
        }
    }

    private func fitsBeside(_ sizes: [CGSize], in width: CGFloat?) -> Bool {
        besideWidth(sizes) <= (width ?? .infinity)
    }

    private func besideWidth(_ sizes: [CGSize]) -> CGFloat {
        sizes.map(\.width).reduce(0, +) + besideSpacing * CGFloat(max(0, sizes.count - 1))
    }
}
