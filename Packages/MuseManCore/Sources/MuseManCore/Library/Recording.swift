import CoreData

public struct Recording: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public let identifier: UUID
    public let date: Date
    public let name: String?
}

extension Recording {
    init?(_ object: RecordingObject) {
        guard let identifier = object.identifier, let date = object.date, object.part != nil else {
            return nil
        }
        id = object.objectID
        self.identifier = identifier
        self.date = date
        name = object.name
    }
}
