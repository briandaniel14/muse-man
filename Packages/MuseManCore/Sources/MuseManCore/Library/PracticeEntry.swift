import CoreData

public struct PracticeEntry: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public let session: PracticeSession.ID
    public let partIdentifier: UUID
    public var rating: Rating
    public var note: String
    public var recordingID: UUID?
    public let date: Date
    public let day: Date
}

extension PracticeEntry {
    init?(_ object: PracticeEntryObject) {
        guard let session = object.session,
              let startDate = session.startDate,
              let partIdentifier = object.partID,
              let date = object.date
        else {
            return nil
        }
        id = object.objectID
        self.session = session.objectID
        self.partIdentifier = partIdentifier
        rating = Rating(rawValue: object.rating) ?? .good
        note = object.note ?? ""
        recordingID = object.recordingID
        self.date = date
        day = Calendar.current.startOfDay(for: startDate)
    }
}
