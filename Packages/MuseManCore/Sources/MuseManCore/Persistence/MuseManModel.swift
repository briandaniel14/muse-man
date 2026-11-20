import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()

        let model = NSManagedObjectModel()
        model.entities = [
            song,
        ]
        return model
    }
}
