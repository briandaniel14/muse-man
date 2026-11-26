import CoreData

public extension PracticeLibrary {
    func recordings(of part: Part.ID) -> [Recording] {
        guard let part = object(part, as: PartObject.self) else {
            return []
        }
        let request = NSFetchRequest<RecordingObject>(entityName: "Recording")
        request.predicate = NSPredicate(format: "part == %@", part)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return fetch(request).compactMap(Recording.init)
    }

    func audio(of recording: Recording.ID) -> Data? {
        object(recording, as: RecordingObject.self)?.audio
    }

    @discardableResult func addRecording(audio: Data, date: Date? = nil, to part: Part.ID) throws -> Recording? {
        guard let part = object(part, as: PartObject.self) else {
            return nil
        }
        let object = RecordingObject(context: context)
        object.identifier = UUID()
        object.date = date ?? now()
        object.audio = audio
        object.part = part
        try save()
        return Recording(object)
    }

    func renameRecording(id: Recording.ID, to name: String) throws {
        guard let object = object(id, as: RecordingObject.self) else {
            return
        }
        object.name = name.trimmedName
        try save()
    }

    func deleteRecording(id: Recording.ID) throws {
        guard let object = object(id, as: RecordingObject.self) else {
            return
        }
        context.delete(object)
        try save()
    }
}
