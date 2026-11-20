import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()
        let resource = resourceEntity()

        relate(
            relationship("resources", to: resource, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("song", to: song, toMany: false),
        )

        let model = NSManagedObjectModel()
        model.entities = [
            song,
            resource,
        ]
        return model
    }
}
