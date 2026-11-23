import CoreData

@objc(SongObject) final nonisolated class SongObject: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var artist: String?
    @NSManaged var key: String?
    @NSManaged var tempo: NSNumber?
    @NSManaged var artworkURL: URL?
}

extension MuseManModel {
    static func songEntity() -> NSEntityDescription {
        entity("Song", className: "SongObject", properties: [
            attribute("title", .string),
            attribute("artist", .string),
            attribute("key", .string),
            attribute("tempo", .integer32),
            attribute("artworkURL", .uri),
        ])
    }
}
