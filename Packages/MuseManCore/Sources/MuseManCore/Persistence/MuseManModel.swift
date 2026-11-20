import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()
        let resource = resourceEntity()
        let instrument = instrumentEntity()
        let part = partEntity()
        let recording = recordingEntity()
        let collection = collectionEntity()
        let collectionItem = collectionItemEntity()
        let practiceSession = practiceSessionEntity()
        let practiceEntry = practiceEntryEntity()

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
            relationship("items", to: collectionItem, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("collection", to: collection, toMany: false),
        )
        relate(
            relationship("collectionItems", to: collectionItem, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("song", to: song, toMany: false),
        )

        relate(
            relationship("recordings", to: recording, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("part", to: part, toMany: false),
        )
        relate(
            relationship("entries", to: practiceEntry, toMany: true, deleteRule: .cascadeDeleteRule),
            inverse: relationship("session", to: practiceSession, toMany: false),
        )

        let model = NSManagedObjectModel()
        model.entities = [
            song,
            resource,
            instrument,
            part,
            recording,
            collection,
            collectionItem,
            practiceSession,
            practiceEntry,
        ]
        return model
    }
}
