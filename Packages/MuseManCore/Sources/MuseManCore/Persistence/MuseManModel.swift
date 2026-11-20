import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()
        let resource = resourceEntity()
        let instrument = instrumentEntity()
        let part = partEntity()

        relate(
            relationship("resources", to: resource, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("song", to: song, toMany: false),
        )
        relate(
            relationship("parts", to: part, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("song", to: song, toMany: false),
        )
        relate(
            relationship("parts", to: part, toMany: true),
            inverse: relationship("instrument", to: instrument, toMany: false),
        )

        let model = NSManagedObjectModel()
        model.entities = [
            song,
            resource,
            instrument,
            part,
        ]
        return model
    }
}
