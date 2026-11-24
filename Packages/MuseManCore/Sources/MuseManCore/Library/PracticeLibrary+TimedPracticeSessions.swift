import CoreData

public extension PracticeLibrary {
    @discardableResult func startPracticeSession() throws -> PracticeSession {
        try runningPracticeSession() ?? addPracticeSession(startDate: now(), duration: nil)
    }

    func runningPracticeSession() -> PracticeSession? {
        let request = NSFetchRequest<PracticeSessionObject>(entityName: "PracticeSession")
        request.predicate = NSPredicate(format: "duration == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        request.fetchLimit = 1
        return fetch(request).first.flatMap(PracticeSession.init)
    }

    func partsToPractise(in session: PracticeSession.ID, picked: [Part], includesDue: Bool = true) -> [Part] {
        let logged = Set(practiceEntries(in: session).map(\.partIdentifier))
        var seen: Set<Part.ID> = []
        return ((includesDue ? practiceNext() : []) + picked).filter { part in
            !logged.contains(part.identifier) && seen.insert(part.id).inserted
        }
    }

    @discardableResult func logPracticeEntry(
        _ draft: PracticeEntryDraft,
        in session: PracticeSession.ID,
    ) throws -> PracticeEntry? {
        guard let session = object(session, as: PracticeSessionObject.self),
              let entry = insertPracticeEntry(draft, in: session)
        else {
            return nil
        }
        reschedule(partIdentifiers: [entry.partID])
        try save()
        return practiceEntries([entry]).first
    }
}
