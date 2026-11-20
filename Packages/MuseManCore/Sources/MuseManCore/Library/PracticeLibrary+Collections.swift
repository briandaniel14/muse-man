import CoreData

public extension PracticeLibrary {
    func collections() -> [Collection] {
        let request = NSFetchRequest<CollectionObject>(entityName: "Collection")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare)),
        ]
        return fetch(request).map(Collection.init)
    }

    func collection(id: Collection.ID) -> Collection? {
        object(id, as: CollectionObject.self).map(Collection.init)
    }

    @discardableResult func addCollection(name: String) throws -> Collection {
        let object = CollectionObject(context: context)
        object.name = name
        try save()
        return Collection(object)
    }

    func updateCollection(_ collection: Collection) throws {
        guard let object = object(collection.id, as: CollectionObject.self) else {
            return
        }
        object.name = collection.name
        try save()
    }

    func deleteCollection(id: Collection.ID) throws {
        guard let object = object(id, as: CollectionObject.self) else {
            return
        }
        context.delete(object)
        try save()
    }

    func songs(in collection: Collection.ID) -> [Song] {
        items(in: collection).compactMap(\.song).map(Song.init)
    }

    func addSong(_ song: Song.ID, to collection: Collection.ID) throws {
        guard let song = object(song, as: SongObject.self),
              let collection = object(collection, as: CollectionObject.self)
        else {
            return
        }
        let items = items(in: collection.objectID)
        guard !items.contains(where: { $0.song == song }) else {
            return
        }
        let item = CollectionItemObject(context: context)
        item.song = song
        item.collection = collection
        item.position = (items.last?.position ?? -1) + 1
        try save()
    }

    func removeSong(_ song: Song.ID, from collection: Collection.ID) throws {
        for item in items(in: collection) where item.song?.objectID == song {
            context.delete(item)
        }
        try save()
    }

    func moveSongs(in collection: Collection.ID, fromOffsets offsets: IndexSet, toOffset destination: Int) throws {
        let items = items(in: collection)
        let order = items.indices.filter { $0 < destination && !offsets.contains($0) }
            + offsets
            + items.indices.filter { $0 >= destination && !offsets.contains($0) }
        for (position, index) in order.enumerated() {
            items[index].position = Int64(position)
        }
        try save()
    }
}

private extension PracticeLibrary {
    func items(in collection: Collection.ID) -> [CollectionItemObject] {
        guard let collection = object(collection, as: CollectionObject.self) else {
            return []
        }
        let request = NSFetchRequest<CollectionItemObject>(entityName: "CollectionItem")
        request.predicate = NSPredicate(format: "collection == %@", collection)
        request.sortDescriptors = [NSSortDescriptor(key: "position", ascending: true)]
        return fetch(request)
    }
}
