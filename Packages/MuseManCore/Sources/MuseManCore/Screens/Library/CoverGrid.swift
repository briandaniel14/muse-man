import SwiftUI

public struct CoverGridLayout: Equatable {
    public let columns: [[URL?]]

    public init(songs: [Song]) {
        let covers = songs.prefix(4).map(\.artworkURL)
        columns = switch covers.count {
        case 0: []
        case 1: [covers]
        case 2: [[covers[0]], [covers[1]]]
        case 3: [[covers[0]], [covers[1], covers[2]]]
        default: [[covers[0], covers[2]], [covers[1], covers[3]]]
        }
    }
}

struct CoverGrid: View {
    let songs: [Song]
    let size: CGFloat

    var body: some View {
        let columns = CoverGridLayout(songs: songs).columns
        if columns.isEmpty {
            SongArtwork(url: nil, size: size)
        } else {
            HStack(spacing: 0) {
                ForEach(columns.indices, id: \.self) { column in
                    VStack(spacing: 0) {
                        ForEach(columns[column].indices, id: \.self) { row in
                            CoverTile(
                                url: columns[column][row],
                                width: size / CGFloat(columns.count),
                                height: size / CGFloat(columns[column].count),
                            )
                        }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: size * Theme.artworkCornerRadiusRatio))
            .accessibilityHidden(true)
        }
    }
}

private struct CoverTile: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ArtworkPlaceholder(size: min(width, height))
        }
        .frame(width: width, height: height)
        .clipped()
    }
}
