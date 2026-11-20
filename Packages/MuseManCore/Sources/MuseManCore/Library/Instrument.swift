import CoreData

public struct Instrument: Identifiable, Hashable {
    public let id: NSManagedObjectID
    public var name: String
}

extension Instrument {
    init(_ object: InstrumentObject) {
        id = object.objectID
        name = object.name ?? ""
    }
}

public struct InstrumentInUseError: Error, Equatable {
    public let partCount: Int

    public init(partCount: Int) {
        self.partCount = partCount
    }
}
