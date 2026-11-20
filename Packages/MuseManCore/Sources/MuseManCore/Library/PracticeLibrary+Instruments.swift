import CoreData

public extension PracticeLibrary {
    func instruments() -> [Instrument] {
        let request = NSFetchRequest<InstrumentObject>(entityName: "Instrument")
        request.sortDescriptors = localizedOrder("name")
        return fetch(request).map(Instrument.init)
    }

    @discardableResult func addInstrument(name: String) throws -> Instrument {
        let object = InstrumentObject(context: context)
        object.name = name
        try save()
        return Instrument(object)
    }

    func updateInstrument(_ instrument: Instrument) throws {
        guard let object = object(instrument.id, as: InstrumentObject.self) else {
            return
        }
        object.name = instrument.name
        try save()
    }

    func deleteInstrument(id: Instrument.ID) throws {
        guard let object = object(id, as: InstrumentObject.self) else {
            return
        }
        let partCount = parts(instrument: id).count
        if partCount > 0 {
            throw InstrumentInUseError(partCount: partCount)
        }
        context.delete(object)
        try save()
    }
}
