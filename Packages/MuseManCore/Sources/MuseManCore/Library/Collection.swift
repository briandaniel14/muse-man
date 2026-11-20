import CoreData

public struct Collection: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public var name: String
}

extension Collection {
    init(_ object: CollectionObject) {
        id = object.objectID
        name = object.name ?? ""
    }
}
