import CoreData

@objc(RecordingObject) final nonisolated class RecordingObject: NSManagedObject {
    @NSManaged var identifier: UUID?
    @NSManaged var date: Date?
    @NSManaged var name: String?
    @NSManaged var audio: Data?
    @NSManaged var part: PartObject?
}

extension MuseManModel {
    static func recordingEntity() -> NSEntityDescription {
        let audio = attribute("audio", .binaryData)
        audio.allowsExternalBinaryDataStorage = true
        return entity("Recording", className: "RecordingObject", properties: [
            attribute("identifier", .uuid),
            attribute("date", .date),
            attribute("name", .string),
            audio,
        ])
    }
}
