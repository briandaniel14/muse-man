import CoreData

@objc(CollectionObject) final nonisolated class CollectionObject: NSManagedObject {
    @NSManaged var name: String?
}

extension MuseManModel {
    static func collectionEntity() -> NSEntityDescription {
        entity("Collection", className: "CollectionObject", properties: [
            attribute("name", .string),
        ])
    }
}
