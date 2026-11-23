import CoreData

@objc(InstrumentObject) final nonisolated class InstrumentObject: NSManagedObject {
    @NSManaged var name: String?
}

extension MuseManModel {
    static func instrumentEntity() -> NSEntityDescription {
        entity("Instrument", className: "InstrumentObject", properties: [
            attribute("name", .string),
        ])
    }
}
