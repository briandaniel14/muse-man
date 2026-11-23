import Foundation

public struct PracticeEntryDraft: Identifiable {
    public let id = UUID()
    public let part: Part
    public var rating: Rating?
    public var note: String
    public var recording: Recording?

    public init(part: Part, rating: Rating? = nil, note: String = "", recording: Recording? = nil) {
        self.part = part
        self.rating = rating
        self.note = note
        self.recording = recording
    }
}
