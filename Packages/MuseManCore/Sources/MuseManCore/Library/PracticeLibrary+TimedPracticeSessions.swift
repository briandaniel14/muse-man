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

    func partsToPractise(in session: PracticeSession.ID, picked: [Part]) -> [Part] {
        let logged = Set(practiceEntries(in: session).map(\.partIdentifier))
        var seen: Set<Part.ID> = []
        return (practiceNext() + picked).filter { part in
            !logged.contains(part.identifier) && seen.insert(part.id).inserted
        }
    }

    @discardableResult func logPracticeEntry(
        _ draft: PracticeEntryDraft,
        in session: PracticeSession.ID,
    ) throws -> PracticeEntry? {
        guard let rating = draft.rating else {
            return nil
        }
        return try addPracticeEntry(
            to: session,
            part: draft.part.id,
            rating: rating,
            note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines),
            recordingID: draft.recording?.identifier,
        )
    }
}
