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

    func keepAudio(_ keep: Bool, of recordings: [Recording]) throws {
        guard !keep else {
            return
        }
        for recording in recordings {
            if let object = object(recording.id, as: RecordingObject.self) {
                context.delete(object)
            }
        }
        try save()
    }
}
