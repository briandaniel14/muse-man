import Foundation

public struct AppleMusicSong: Hashable {
    public let id: String
    public let url: URL

    public init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
