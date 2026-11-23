import CoreData

public struct Song: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public var title: String
    public var artist: String
    public var key: String?
    public var tempo: Int?
    public var artworkURL: URL?
    public var note: String
}

extension Song {
    init(_ object: SongObject) {
        id = object.objectID
        title = object.title ?? ""
        artist = object.artist ?? ""
        key = object.key
        tempo = object.tempo?.intValue
        artworkURL = object.artworkURL
        note = object.note ?? ""
    }
}
