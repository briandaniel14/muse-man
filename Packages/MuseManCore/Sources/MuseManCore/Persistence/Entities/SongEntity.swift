import CoreData

@objc(SongObject) final nonisolated class SongObject: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var artist: String?
    @NSManaged var key: String?
    @NSManaged var tempo: NSNumber?
    @NSManaged var artworkURL: URL?
    @NSManaged var note: String?
    @NSManaged var appleMusicID: String?
    @NSManaged var appleMusicURL: URL?
}

extension SongObject {
    var appleMusicSong: AppleMusicSong? {
        get {
            guard let appleMusicID, let appleMusicURL else {
                return nil
            }
            return AppleMusicSong(id: appleMusicID, url: appleMusicURL)
        }
        set {
            appleMusicID = newValue?.id
            appleMusicURL = newValue?.url
        }
    }
}

extension MuseManModel {
    static func songEntity() -> NSEntityDescription {
        entity("Song", className: "SongObject", properties: [
            attribute("title", .string),
            attribute("artist", .string),
            attribute("key", .string),
            attribute("tempo", .integer32),
            attribute("artworkURL", .uri),
            attribute("note", .string),
            attribute("appleMusicID", .string),
            attribute("appleMusicURL", .uri),
        ])
    }
}
