import CoreData

@objc(CollectionItemObject) final nonisolated class CollectionItemObject: NSManagedObject {
    @NSManaged var position: Int64
    @NSManaged var collection: CollectionObject?
    @NSManaged var song: SongObject?
}

extension MuseManModel {
    static func collectionItemEntity() -> NSEntityDescription {
        entity("CollectionItem", className: "CollectionItemObject", properties: [
            attribute("position", .integer64, defaultValue: 0),
        ])
    }
}
