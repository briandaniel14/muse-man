import CoreData

@objc(CollectionObject) final nonisolated class CollectionObject: NSManagedObject {
    @NSManaged var name: String?
    @NSManaged var note: String?
}

extension MuseManModel {
    static func collectionEntity() -> NSEntityDescription {
        entity("Collection", className: "CollectionObject", properties: [
            attribute("name", .string),
            attribute("note", .string),
        ])
    }
}
