import CoreData

@objc(PracticeSessionObject) final nonisolated class PracticeSessionObject: NSManagedObject {
    @NSManaged var startDate: Date?
    @NSManaged var duration: NSNumber?
    @NSManaged var note: String?
    @NSManaged var entries: Set<PracticeEntryObject>?
}

extension MuseManModel {
    static func practiceSessionEntity() -> NSEntityDescription {
        entity("PracticeSession", className: "PracticeSessionObject", properties: [
            attribute("startDate", .date),
            attribute("duration", .double),
            attribute("note", .string),
        ])
    }
}
