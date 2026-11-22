import CoreData

public struct Recording: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public let identifier: UUID
    public let date: Date
    public let name: String?
    public let part: Part.ID
}

extension Recording {
    init?(_ object: RecordingObject) {
        guard let identifier = object.identifier, let date = object.date, let part = object.part else {
            return nil
        }
        id = object.objectID
        self.identifier = identifier
        self.date = date
        name = object.name
        self.part = part.objectID
    }
}
