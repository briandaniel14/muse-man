import Foundation
import MusicKit

enum SongCatalog {
    static func search(_ term: String) async -> [CatalogSong] {
        guard await isAuthorized() else {
            return []
        }
        return await songs(matching: term, limit: 15)
    }

    static func warmUp() async {
        guard MusicAuthorization.currentStatus == .authorized else {
            return
        }
        _ = await songs(matching: "song", limit: 1)
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
    static func isAuthorized() async -> Bool {
        if MusicAuthorization.currentStatus == .authorized {
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
