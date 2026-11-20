import CoreData

public extension PracticeLibrary {
    func practiceSessions() -> [PracticeSession] {
        let request = NSFetchRequest<PracticeSessionObject>(entityName: "PracticeSession")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        return fetch(request).compactMap(PracticeSession.init)
    }

    func practiceSession(id: PracticeSession.ID) -> PracticeSession? {
        object(id, as: PracticeSessionObject.self).flatMap(PracticeSession.init)
    }

    @discardableResult func addPracticeSession(
        startDate: Date,
        duration: TimeInterval?,
        note: String = "",
    ) throws -> PracticeSession {
        let object = PracticeSessionObject(context: context)
        object.startDate = startDate
        object.duration = duration.map { NSNumber(value: $0) }
        object.note = note
        try save()
        return PracticeSession(id: object.objectID, startDate: startDate, duration: duration, note: note)
    }

    func finishPracticeSession(id: PracticeSession.ID) throws {
        guard let object = object(id, as: PracticeSessionObject.self) else {
            return
        }
        if object.entries?.isEmpty ?? true {
            context.delete(object)
        } else if object.duration == nil, let startDate = object.startDate {
            object.duration = NSNumber(value: now().timeIntervalSince(startDate))
        }
        try save()
    }

    func practiceEntries(in session: PracticeSession.ID) -> [PracticeEntry] {
        let request = NSFetchRequest<PracticeEntryObject>(entityName: "PracticeEntry")
        request.predicate = NSPredicate(format: "session == %@", session)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return fetch(request).compactMap(PracticeEntry.init)
    }

    @discardableResult func addPracticeEntry(
        to session: PracticeSession.ID,
        part: Part.ID,
        rating: Rating,
        note: String = "",
        recordingID: UUID? = nil,
    ) throws -> PracticeEntry? {
        guard let session = object(session, as: PracticeSessionObject.self),
              let part = object(part, as: PartObject.self),
              let partID = part.identifier
        else {
            return nil
        }
        let entry = PracticeEntryObject(context: context)
        entry.session = session
        entry.partID = partID
        entry.rating = rating.rawValue
        entry.note = note
        entry.recordingID = recordingID
        entry.date = now()
        if part.status == Part.Status.wantToLearn.rawValue {
            part.status = Part.Status.learning.rawValue
        }
        reschedule(part)
        try save()
        return PracticeEntry(entry)
    }

    func part(identifier: UUID) -> Part? {
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(format: "identifier == %@", identifier as NSUUID)
        request.fetchLimit = 1
        return fetch(request).first.flatMap(Part.init)
    }
}
