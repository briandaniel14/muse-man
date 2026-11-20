import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()
        let resource = resourceEntity()
        let instrument = instrumentEntity()
        let part = partEntity()
        let recording = recordingEntity()

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

        relate(
            relationship("recordings", to: recording, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("part", to: part, toMany: false),
        )

        let model = NSManagedObjectModel()
        model.entities = [
            song,
            resource,
            instrument,
            part,
            recording,
        ]
        return model
    }
}
