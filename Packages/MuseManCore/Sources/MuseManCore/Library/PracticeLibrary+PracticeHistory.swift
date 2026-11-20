import CoreData

public extension PracticeLibrary {
    func practiceEntries(of part: Part.ID) -> [PracticeEntry] {
        guard let identifier = object(part, as: PartObject.self)?.identifier else {
            return []
        }
        let request = NSFetchRequest<PracticeEntryObject>(entityName: "PracticeEntry")
        request.predicate = NSPredicate(format: "partID == %@", identifier as NSUUID)
        request.sortDescriptors = [
            NSSortDescriptor(key: "session.startDate", ascending: false),
            NSSortDescriptor(key: "date", ascending: false),
        ]
        return fetch(request).compactMap(PracticeEntry.init)
    }

    func updatePracticeEntry(_ entry: PracticeEntry) throws {
        guard let object = object(entry.id, as: PracticeEntryObject.self) else {
            return
        }
        object.rating = entry.rating.rawValue
        object.note = entry.note
        object.recordingID = entry.recordingID
        reschedule(partIdentifiers: [object.partID])
        try save()
    }

    func deletePracticeEntry(id: PracticeEntry.ID) throws {
        guard let object = object(id, as: PracticeEntryObject.self) else {
            return
        }
        let session = object.session
        context.delete(object)
        reschedule(partIdentifiers: [object.partID])
        deleteFinishedIfEmpty([session])
        try save()
    }

    func updatePracticeSession(_ session: PracticeSession) throws {
        guard let object = object(session.id, as: PracticeSessionObject.self) else {
            return
        }
        let moved = object.startDate != session.startDate
        object.startDate = session.startDate
        if let duration = session.duration {
            object.duration = NSNumber(value: duration)
        }
        object.note = session.note
        if moved {
            reschedule(partIdentifiers: object.entries?.map(\.partID) ?? [])
        }
        try save()
    }

    func deletePracticeSession(id: PracticeSession.ID) throws {
        guard let object = object(id, as: PracticeSessionObject.self) else {
            return
        }
        let entries = object.entries ?? []
        entries.forEach(context.delete)
        context.delete(object)
        reschedule(partIdentifiers: entries.map(\.partID))
        try save()
    }
}

extension PracticeLibrary {
    func reschedule(partIdentifiers: some Sequence<UUID?>) {
        let identifiers = Set(partIdentifiers.compactMap(\.self))
        guard !identifiers.isEmpty else {
            return
        }
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(format: "identifier IN %@", identifiers.map { $0 as NSUUID })
        fetch(request).forEach(reschedule)
    }

    func deleteFinishedIfEmpty(_ sessions: some Sequence<PracticeSessionObject?>) {
        for session in Set(sessions.compactMap(\.self)) where session.duration != nil {
            if session.entries?.allSatisfy(\.isDeleted) ?? true {
                context.delete(session)
            }
        }
    }

    func deletePracticeEntries(ofParts identifiers: [UUID?]) {
        let request = NSFetchRequest<PracticeEntryObject>(entityName: "PracticeEntry")
        request.predicate = NSPredicate(format: "partID IN %@", identifiers.compactMap { $0 as NSUUID? })
        let entries = fetch(request)
        entries.forEach(context.delete)
        deleteFinishedIfEmpty(entries.map(\.session))
    }
}
