public enum PlaybackBarContent: Equatable {
    case fullSong

    public static func shown(appleMusicSong: AppleMusicSong?, canPlayCatalogContent: Bool) -> PlaybackBarContent? {
        guard appleMusicSong != nil else {
            return nil
        }
        return canPlayCatalogContent ? .fullSong : nil
    }
}
