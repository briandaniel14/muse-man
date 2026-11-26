import CoreData

public struct PracticeSession: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public var startDate: Date
    public var duration: TimeInterval?
    public var note: String
    public var name: String?
}

extension PracticeSession {
    init?(_ object: PracticeSessionObject) {
        guard let startDate = object.startDate else {
            return nil
        }
        id = object.objectID
        self.startDate = startDate
        duration = object.duration?.doubleValue
        note = object.note ?? ""
        name = object.name
    }
}
