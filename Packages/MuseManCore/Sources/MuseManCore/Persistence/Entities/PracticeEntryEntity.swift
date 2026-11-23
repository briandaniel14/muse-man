import CoreData

@objc(PracticeEntryObject) final nonisolated class PracticeEntryObject: NSManagedObject {
    @NSManaged var partID: UUID?
    @NSManaged var rating: Int16
    @NSManaged var note: String?
    @NSManaged var recordingID: UUID?
    @NSManaged var date: Date?
    @NSManaged var session: PracticeSessionObject?
}

extension MuseManModel {
    static func practiceEntryEntity() -> NSEntityDescription {
        entity("PracticeEntry", className: "PracticeEntryObject", properties: [
            attribute("partID", .uuid),
            attribute("rating", .integer16, defaultValue: Rating.good.rawValue),
            attribute("note", .string),
            attribute("recordingID", .uuid),
            attribute("date", .date),
        ])
    }
}
