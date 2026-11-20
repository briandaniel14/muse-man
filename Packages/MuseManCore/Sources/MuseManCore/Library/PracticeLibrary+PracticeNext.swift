import CoreData

public extension PracticeLibrary {
    func practiceNext() -> [Part] {
        let request = NSFetchRequest<PartObject>(entityName: "Part")
        request.predicate = NSPredicate(
            format: "status != %d AND dueDate <= %@",
            Part.Status.wantToLearn.rawValue,
            today as NSDate,
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: "dueDate", ascending: true),
            NSSortDescriptor(
                key: "song.title",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare),
            ),
            NSSortDescriptor(
                key: "instrument.name",
                ascending: true,
                selector: #selector(NSString.localizedStandardCompare),
            ),
            NSSortDescriptor(key: "label", ascending: true, selector: #selector(NSString.localizedStandardCompare)),
        ]
        return fetch(request).compactMap(Part.init)
    }
}
