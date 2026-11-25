import Foundation

public enum PlaybackBarContent: Equatable {
    case fullSong
    case preview(URL)

    public static func shown(
        appleMusicSong: AppleMusicSong?,
        canPlayCatalogContent: Bool,
        isSongFound: Bool,
        previewURL: URL?,
    ) -> PlaybackBarContent? {
        guard appleMusicSong != nil else {
            return nil
        }
        if canPlayCatalogContent, isSongFound {
            return .fullSong
        }
        return previewURL.map(PlaybackBarContent.preview)
    }
}
