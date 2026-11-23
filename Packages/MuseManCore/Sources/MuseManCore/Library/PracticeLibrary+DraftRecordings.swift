import CoreData

public extension PracticeLibrary {
    @discardableResult func replaceRecording(
        of draft: inout PracticeEntryDraft,
        withAudio audio: Data,
        date: Date? = nil,
    ) throws -> [Recording] {
        guard let recording = try addRecording(audio: audio, date: date, to: draft.part.id) else {
            return []
        }
        return draft.attach(recording, madeForDraft: true)
    }

    func discardAudio(of draftAudio: [Recording]) throws {
        for recording in draftAudio {
            if let object = object(recording.id, as: RecordingObject.self) {
                context.delete(object)
            }
        }
        try save()
    }
}
