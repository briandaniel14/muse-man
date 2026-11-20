import CoreData

enum MuseManModel {
    static let shared = make()

    private static func make() -> NSManagedObjectModel {
        let song = songEntity()
        let resource = resourceEntity()
        let instrument = instrumentEntity()
        let part = partEntity()
        let collection = collectionEntity()
        let collectionItem = collectionItemEntity()

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

        let model = NSManagedObjectModel()
        model.entities = [
            song,
            resource,
            instrument,
            part,
            collection,
            collectionItem,
        ]
        return model
    }
}
