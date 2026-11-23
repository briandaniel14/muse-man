import CoreData

public extension PracticeLibrary {
    func songs(matching search: String = "") -> [Song] {
        let request = NSFetchRequest<SongObject>(entityName: "Song")
        let search = search.trimmingCharacters(in: .whitespaces)
        if !search.isEmpty {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR artist CONTAINS[cd] %@", search, search)
        }
        request.sortDescriptors = localizedOrder("title", "artist")
        return fetch(request).map(Song.init)
    }

    @discardableResult func addSong(
        title: String,
        artist: String,
        key: String? = nil,
        tempo: Int? = nil,
        artworkURL: URL? = nil,
    ) throws -> Song {
        let object = SongObject(context: context)
        object.set(title: title, artist: artist, key: key, tempo: tempo, artworkURL: artworkURL)
        try save()
        return Song(object)
    }

    func updateSong(_ song: Song) throws {
        guard let object = object(song.id, as: SongObject.self) else {
            return
        }
        object.set(
            title: song.title,
            artist: song.artist,
            key: song.key,
            tempo: song.tempo,
            artworkURL: song.artworkURL,
        )
        try save()
    }

    func deleteSong(id: Song.ID) throws {
        guard let object = object(id, as: SongObject.self) else {
            return
        }
        let parts = NSFetchRequest<PartObject>(entityName: "Part")
        parts.predicate = NSPredicate(format: "song == %@", object)
        deletePracticeEntries(ofParts: fetch(parts).map(\.identifier))
        context.delete(object)
        try save()
    }
}

private extension SongObject {
    func set(title: String, artist: String, key: String?, tempo: Int?, artworkURL: URL?) {
        self.title = title
        self.artist = artist
        self.key = key
        self.tempo = tempo.map { NSNumber(value: $0) }
        self.artworkURL = artworkURL
    }
}
