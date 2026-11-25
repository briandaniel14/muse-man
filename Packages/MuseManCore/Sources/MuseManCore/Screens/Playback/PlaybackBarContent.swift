import Foundation

public enum PlaybackBarContent: Equatable {
    case fullSong
    case preview(URL)

    public static func shown(
        appleMusicSong: AppleMusicSong?,
        canPlayCatalogContent: Bool,
        previewURL: URL?,
    ) -> PlaybackBarContent? {
        guard appleMusicSong != nil else {
            return nil
        }
        if canPlayCatalogContent {
            return .fullSong
        }
        return previewURL.map(PlaybackBarContent.preview)
    }
}
