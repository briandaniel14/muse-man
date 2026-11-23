import Foundation

public struct PracticeEntryDraft: Identifiable {
    public let id = UUID()
    public let part: Part
    public var rating: Rating?
    public var note: String
    public private(set) var recording: Recording?
    private var isRecordingMadeForDraft = false

    public init(part: Part, rating: Rating? = nil, note: String = "", recording: Recording? = nil) {
        self.part = part
        self.rating = rating
        self.note = note
        self.recording = recording
    }

    public var draftAudio: [Recording] {
        isRecordingMadeForDraft ? recording.map { [$0] } ?? [] : []
    }

    @discardableResult public mutating func replaceRecording(with recording: Recording?) -> [Recording] {
        attach(recording, madeForDraft: false)
    }

    mutating func attach(_ recording: Recording?, madeForDraft: Bool) -> [Recording] {
        guard recording != self.recording else {
            return []
        }
        let previousDraftAudio = draftAudio
        self.recording = recording
        isRecordingMadeForDraft = madeForDraft
        return previousDraftAudio
    }
}
