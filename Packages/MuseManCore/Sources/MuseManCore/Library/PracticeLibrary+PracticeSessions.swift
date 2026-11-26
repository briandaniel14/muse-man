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

    func renamePracticeSession(id: PracticeSession.ID, to name: String) throws {
        guard let object = object(id, as: PracticeSessionObject.self) else {
            return
        }
        object.name = name.trimmedName
        try save()
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
        return practiceEntries(fetch(request))
    }

    func practisedSongs(in session: PracticeSession.ID) -> [Song] {
        var seen = Set<Song.ID>()
        return practiceEntries(in: session).reversed().compactMap(\.part?.song).filter { seen.insert($0.id).inserted }
    }

    @discardableResult func addPracticeEntry(
        to session: PracticeSession.ID,
        part: Part.ID,
        rating: Rating?,
        note: String = "",
        recordingID: UUID? = nil,
    ) throws -> PracticeEntry? {
        guard let session = object(session, as: PracticeSessionObject.self),
              let part = object(part, as: PartObject.self),
              let entry = insertPracticeEntry(
                  in: session,
                  part: part,
                  rating: rating,
                  note: note,
                  recordingID: recordingID,
              )
        else {
            return nil
        }
        reschedule(part)
        try save()
        return practiceEntries([entry]).first
    }
}

extension PracticeLibrary {
    func insertPracticeEntry(_ draft: PracticeEntryDraft, in session: PracticeSessionObject) -> PracticeEntryObject? {
        guard let part = object(draft.part.id, as: PartObject.self) else {
            return nil
        }
        return insertPracticeEntry(
            in: session,
            part: part,
            rating: draft.rating,
            note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines),
            recordingID: draft.recording?.identifier,
        )
    }

    @discardableResult func insertPracticeEntry(
        in session: PracticeSessionObject,
        part: PartObject,
        rating: Rating?,
        note: String,
        recordingID: UUID?,
    ) -> PracticeEntryObject? {
        guard let partIdentifier = part.identifier else {
            return nil
        }
        let entry = PracticeEntryObject(context: context)
        entry.session = session
        entry.partID = partIdentifier
        entry.savedRating = rating
        entry.note = note
        entry.recordingID = recordingID
        entry.date = now()
        if part.status == Part.Status.wantToLearn.rawValue {
            part.status = Part.Status.learning.rawValue
        }
        return entry
    }
}
