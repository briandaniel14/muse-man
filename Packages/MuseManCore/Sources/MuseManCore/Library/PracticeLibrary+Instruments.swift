import CoreData

public extension PracticeLibrary {
    func instruments() -> [Instrument] {
        let request = NSFetchRequest<InstrumentObject>(entityName: "Instrument")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare)),
        ]
        return fetch(request).map(Instrument.init)
    }

    @discardableResult func addInstrument(name: String) throws -> Instrument {
        let object = InstrumentObject(context: context)
        object.name = name
        try save()
        return Instrument(object)
    }
}
