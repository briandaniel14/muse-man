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
        var parts: [PartObject] = []
        for draft in drafts {
            guard let rating = draft.rating, let part = object(draft.part.id, as: PartObject.self) else {
                continue
            }
            insertPracticeEntry(
                in: session,
                part: part,
                rating: rating,
                note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines),
                recordingID: draft.recording?.identifier,
            )
            if !parts.contains(part) {
                parts.append(part)
            }
        }
        parts.forEach(reschedule)
        try save()
        return PracticeSession(session)
    }
}
