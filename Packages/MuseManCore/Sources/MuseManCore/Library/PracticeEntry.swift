import CoreData

public struct PracticeEntry: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public let partIdentifier: UUID
    public let part: Part?
    public var rating: Rating?
    public var note: String
    public private(set) var recordingID: UUID?
    public var recording: Recording? {
        didSet {
            recordingID = recording?.identifier
        }
    }

    public let day: Date
}

extension PracticeEntry {
    init?(_ object: PracticeEntryObject, parts: [UUID: Part], recordings: [UUID: Recording]) {
        guard let startDate = object.session?.startDate, let partIdentifier = object.partID, object.date != nil else {
            return nil
        }
        id = object.objectID
        self.partIdentifier = partIdentifier
        part = parts[partIdentifier]
        rating = object.savedRating
        note = object.note ?? ""
        recordingID = object.recordingID
        recording = object.recordingID.flatMap { recordings[$0] }
        day = Calendar.current.startOfDay(for: startDate)
    }
}
