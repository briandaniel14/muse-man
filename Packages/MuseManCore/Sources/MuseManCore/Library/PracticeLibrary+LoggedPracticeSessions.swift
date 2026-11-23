import CoreData

public extension PracticeLibrary {
    func startDate(hoursAgo: Int, minutesAgo: Int) -> Date {
        now().addingTimeInterval(-TimeInterval((hoursAgo * 60 + minutesAgo) * 60))
    }

    func canLogPracticeSession(duration: TimeInterval, drafts: [PracticeEntryDraft]) -> Bool {
        duration > 0 && !drafts.isEmpty && drafts.allSatisfy { $0.rating != nil }
    }

    @discardableResult func logPracticeSession(
        startDate: Date,
        duration: TimeInterval,
        note: String,
        drafts: [PracticeEntryDraft],
    ) throws -> PracticeSession? {
        guard canLogPracticeSession(duration: duration, drafts: drafts) else {
            return nil
        }
        let session = PracticeSessionObject(context: context)
        session.startDate = startDate
        session.duration = NSNumber(value: duration)
        session.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let entries = drafts.compactMap { insertPracticeEntry($0, in: session) }
        guard !entries.isEmpty else {
            context.delete(session)
            return nil
        }
        reschedule(partIdentifiers: entries.map(\.partID))
        try save()
        return PracticeSession(session)
    }
}
