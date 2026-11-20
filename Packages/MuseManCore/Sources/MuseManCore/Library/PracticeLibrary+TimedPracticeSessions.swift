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
}
