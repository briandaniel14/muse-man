import CoreData
import Observation

@Observable public final class PracticeLibrary {
    @ObservationIgnored let context: NSManagedObjectContext
    @ObservationIgnored let now: () -> Date
    private var changes = 0

    public init(container: NSPersistentContainer, now: @escaping () -> Date = Date.init) {
        context = container.viewContext
        self.now = now
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextObjectsDidChange,
            object: context,
            queue: nil,
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.changes += 1
            }
        }
    }

    func fetch<Object: NSManagedObject>(_ request: NSFetchRequest<Object>) -> [Object] {
        _ = changes
        return (try? context.fetch(request)) ?? []
    }

    func object<Object: NSManagedObject>(_ id: NSManagedObjectID, as _: Object.Type) -> Object? {
        _ = changes
        guard let object = try? context.existingObject(with: id) as? Object, !object.isDeleted else {
            return nil
        }
        return object
    }

    var today: Date {
        Calendar.current.startOfDay(for: now())
    }

    func save() throws {
        try context.save()
    }

    func localizedOrder(_ keys: String...) -> [NSSortDescriptor] {
        keys.map { NSSortDescriptor(key: $0, ascending: true, selector: #selector(NSString.localizedStandardCompare)) }
    }
}
