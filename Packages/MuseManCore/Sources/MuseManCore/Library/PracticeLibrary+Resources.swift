import CoreData

public extension PracticeLibrary {
    func resources(for songID: Song.ID) -> [Resource] {
        guard let song = object(songID, as: SongObject.self) else {
            return []
        }
        let request = NSFetchRequest<ResourceObject>(entityName: "Resource")
        request.predicate = NSPredicate(format: "song == %@", song)
        return fetch(request)
            .map(Resource.init)
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func resource(id: Resource.ID) -> Resource? {
        object(id, as: ResourceObject.self).map(Resource.init)
    }

    @discardableResult func addResource(url: URL, title: String? = nil, to songID: Song.ID) throws -> Resource? {
        guard let song = object(songID, as: SongObject.self) else {
            return nil
        }
        let object = ResourceObject(context: context)
        object.song = song
        object.set(url: url, title: title)
        try save()
        return Resource(object)
    }

    func updateResource(_ resource: Resource) throws {
        guard let object = object(resource.id, as: ResourceObject.self) else {
            return
        }
        object.set(url: resource.url, title: resource.title)
        try save()
    }

    func deleteResource(id: Resource.ID) throws {
        guard let object = object(id, as: ResourceObject.self) else {
            return
        }
        context.delete(object)
        try save()
    }
}

private extension ResourceObject {
    func set(url: URL, title: String?) {
        self.url = url.absoluteString
        let title = title?.trimmingCharacters(in: .whitespaces)
        self.title = title?.isEmpty == false ? title : nil
    }
}
