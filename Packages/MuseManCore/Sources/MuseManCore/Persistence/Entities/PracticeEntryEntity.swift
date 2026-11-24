import CoreData

@objc(PracticeEntryObject) final nonisolated class PracticeEntryObject: NSManagedObject {
    @NSManaged var partID: UUID?
    @NSManaged private var rating: NSNumber?
    @NSManaged var note: String?
    @NSManaged var recordingID: UUID?
    @NSManaged var date: Date?
    @NSManaged var session: PracticeSessionObject?

    var savedRating: Rating? {
        get {
            rating.flatMap { Rating(rawValue: $0.int16Value) }
        }
        set {
            rating = newValue.map { NSNumber(value: $0.rawValue) }
        }
    }
}

extension MuseManModel {
    static func practiceEntryEntity() -> NSEntityDescription {
        entity("PracticeEntry", className: "PracticeEntryObject", properties: [
            attribute("partID", .uuid),
            attribute("rating", .integer16),
            attribute("note", .string),
            attribute("recordingID", .uuid),
            attribute("date", .date),
        ])
    }
}
