import Foundation
import MusicKit

enum SongCatalog {
    static func search(_ term: String) async -> [CatalogSong] {
        guard await MusicAuthorization.request() == .authorized else {
            return []
        }
        var request = MusicCatalogSearchRequest(term: term, types: [MusicKit.Song.self])
        request.limit = 15
        let response = try? await request.response()
        return response?.songs.map(CatalogSong.init) ?? []
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
