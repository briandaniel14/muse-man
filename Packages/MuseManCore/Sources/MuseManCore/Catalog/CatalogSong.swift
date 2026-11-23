import Foundation
import MusicKit

public struct CatalogSong: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String?
    public let artwork: Artwork?
    public let isrc: String?

    public init(
        id: String,
        title: String,
        artist: String,
        album: String?,
        artwork: Artwork?,
        isrc: String?,
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.isrc = isrc
    }
}

public extension CatalogSong {
    var artworkURL: URL? {
        artwork?.url(width: 600, height: 600)
    }

    var thumbnailURL: URL? {
        artwork?.url(width: 132, height: 132)
    }

    func versionISRCs(in results: [CatalogSong]) -> [String] {
        var seen = Set<String>()
        return ([self] + results.filter(isVersion))
            .compactMap(\.isrc)
            .filter { seen.insert($0).inserted }
    }
}

extension CatalogSong {
    init(_ song: MusicKit.Song) {
        id = song.id.rawValue
        title = song.title
        artist = song.artistName
        album = song.albumTitle
        artwork = song.artwork
        isrc = song.isrc
    }
}

private extension CatalogSong {
    var baseTitle: String {
        title
            .replacing(/\s*[\(\[].*?[\)\]]/, with: "")
            .replacing(/\s+-\s+.*$/, with: "")
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
    }

    func isVersion(_ other: CatalogSong) -> Bool {
        artist.lowercased() == other.artist.lowercased() && baseTitle == other.baseTitle
    }
}
