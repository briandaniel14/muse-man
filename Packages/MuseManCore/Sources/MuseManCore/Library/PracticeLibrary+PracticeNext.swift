import CoreData

public extension PracticeLibrary {
    func practiceNext() -> [Part] {
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(
            format: "status != %d AND dueDate <= %@",
            Part.Status.wantToLearn.rawValue,
            today as NSDate,
        )
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
            + localizedOrder("song.title", "instrument.name", "label")
        return fetch(request).compactMap(Part.init)
    }
}
