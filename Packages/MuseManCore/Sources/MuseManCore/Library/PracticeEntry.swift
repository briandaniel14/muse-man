import CoreData

public struct PracticeEntry: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public let session: PracticeSession.ID
    public let partIdentifier: UUID
    public let part: Part?
    public var rating: Rating
    public var note: String
    public private(set) var recordingID: UUID?
    public var recording: Recording? {
        didSet {
            recordingID = recording?.identifier
        }
    }

    public let date: Date
    public let day: Date
}

extension PracticeEntry {
    init?(_ object: PracticeEntryObject, parts: [UUID: Part], recordings: [UUID: Recording]) {
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
        part = parts[partIdentifier]
        rating = Rating(rawValue: object.rating) ?? .good
        note = object.note ?? ""
        recordingID = object.recordingID
        recording = object.recordingID.flatMap { recordings[$0] }
        self.date = date
        day = Calendar.current.startOfDay(for: startDate)
    }
}
