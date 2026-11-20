import CoreData

public extension PracticeLibrary {
    func parts(of song: Song.ID) -> [Part] {
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(format: "song == %@", song)
        request.sortDescriptors = [
            NSSortDescriptor(
                key: "instrument.name",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare),
            ),
            NSSortDescriptor(key: "label", ascending: true, selector: #selector(NSString.localizedStandardCompare)),
        ]
        return fetch(request).compactMap(Part.init)
    }

    func part(id: Part.ID) -> Part? {
        object(id, as: PartObject.self).flatMap(Part.init)
    }

    @discardableResult func addPart(to song: Song.ID, instrument: Instrument.ID, label: String? = nil) throws -> Part? {
        guard let song = object(song, as: SongObject.self),
              let instrument = object(instrument, as: InstrumentObject.self)
        else {
            return nil
        }
        let object = PartObject(context: context)
        object.identifier = UUID()
        object.song = song
        object.instrument = instrument
        object.label = label
        try save()
        return Part(object)
    }

    func updatePart(_ part: Part) throws {
        guard let object = object(part.id, as: PartObject.self) else {
            return
        }
        object.label = part.label
        object.status = part.status.rawValue
        if part.status != .wantToLearn, object.dueDate == nil {
            object.dueDate = today
        }
        object.note = part.note
        try save()
    }

    func deletePart(id: Part.ID) throws {
        guard let object = object(id, as: PartObject.self) else {
            return
        }
        context.delete(object)
        try save()
    }
}
