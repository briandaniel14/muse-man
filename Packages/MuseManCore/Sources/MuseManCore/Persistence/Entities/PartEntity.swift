import CoreData

@objc(PartObject) final nonisolated class PartObject: NSManagedObject {
    @NSManaged var identifier: UUID?
    @NSManaged var owner: String?
    @NSManaged var label: String?
    @NSManaged var status: Int16
    @NSManaged var note: String?
    @NSManaged var dueDate: Date?
    @NSManaged var song: SongObject?
    @NSManaged var instrument: InstrumentObject?
}

extension MuseManModel {
    static func partEntity() -> NSEntityDescription {
        entity("Part", className: "PartObject", properties: [
            attribute("identifier", .uuid),
            attribute("owner", .string, defaultValue: ""),
            attribute("label", .string),
            attribute("status", .integer16, defaultValue: 0),
            attribute("note", .string),
            attribute("dueDate", .date),
        ])
    }
}
