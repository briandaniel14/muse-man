import Foundation

public struct PracticeEntryDraft: Identifiable {
    public let id = UUID()
    public let part: Part
    public var rating: Rating?
    public var note: String
    public var recordingID: UUID?

    public init(part: Part, rating: Rating? = nil, note: String = "", recordingID: UUID? = nil) {
        self.part = part
        self.rating = rating
        self.note = note
        self.recordingID = recordingID
    }
}
