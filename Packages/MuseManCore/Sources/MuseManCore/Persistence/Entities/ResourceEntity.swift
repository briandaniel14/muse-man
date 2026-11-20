import CoreData

@objc(ResourceObject) final nonisolated class ResourceObject: NSManagedObject {
    @NSManaged var url: String?
    @NSManaged var title: String?
    @NSManaged var song: SongObject?
}

extension MuseManModel {
    static func resourceEntity() -> NSEntityDescription {
        entity("Resource", className: "ResourceObject", properties: [
            attribute("url", .string),
            attribute("title", .string),
        ])
    }
}
