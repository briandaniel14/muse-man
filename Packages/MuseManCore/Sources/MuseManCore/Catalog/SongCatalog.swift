import Foundation
import MusicKit

enum SongCatalog {
    static func search(_ term: String) async -> [CatalogSong] {
        guard await requestAuthorization() else {
            return []
        }
        return await songs(matching: term, limit: 15)
    }

    static func warmUp() async {
        guard isAuthorized else {
            return
        }
        _ = await songs(matching: warmUpTerm, limit: 1)
    }

    static func canPlayCatalogContent() async -> Bool {
        guard await requestAuthorization() else {
            return false
        }
        return await (try? MusicSubscription.current)?.canPlayCatalogContent ?? false
    }

    static func song(_ appleMusicSong: AppleMusicSong) async -> MusicKit.Song? {
        guard await requestAuthorization() else {
            return nil
        }
        let request = MusicCatalogResourceRequest<MusicKit.Song>(
            matching: \.id,
            equalTo: MusicItemID(appleMusicSong.id),
        )
        return try? await request.response().items.first
    }

    static func details(isrcs: [String]) async -> SongDetails? {
        let ids = isrcs.joined(separator: ",")
        guard
            let url = URL(string: "https://api.reccobeats.com/v1/audio-features?ids=\(ids)"),
            let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            return nil
        }
        return SongDetails(audioFeatures: data, preferring: isrcs)
    }
}

private extension SongCatalog {
    static let warmUpTerm = "song"

    static var isAuthorized: Bool {
        MusicAuthorization.currentStatus == .authorized
    }

    static func requestAuthorization() async -> Bool {
        if isAuthorized {
            return true
        }
        return await MusicAuthorization.request() == .authorized
    }

    static func songs(matching term: String, limit: Int) async -> [CatalogSong] {
        var request = MusicCatalogSearchRequest(term: term, types: [MusicKit.Song.self])
        request.limit = limit
        let response = try? await request.response()
        return response?.songs.map(CatalogSong.init) ?? []
    }
}
