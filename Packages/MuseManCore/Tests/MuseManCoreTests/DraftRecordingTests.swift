import Foundation
import MuseManCore
import Testing

struct DraftRecordingTests {
    let audio = Data("tonight's take".utf8)

    @Test func `a Recording made for a Practice Entry Draft is attached to it and held on the Part`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        var draft = PracticeEntryDraft(part: part)

        try library.replaceRecording(of: &draft, withAudio: audio)

        let made = try #require(draft.recording)
        #expect(draft.unsavedRecordings == [made])
        #expect(library.recordings(of: part.id).map(\.id) == [made.id])
        #expect(library.audio(of: made.id) == audio)
    }

    @Test func `discarding Practice Entry Drafts but keeping their audio leaves the Recordings`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        var draft = PracticeEntryDraft(part: part)
        try library.replaceRecording(of: &draft, withAudio: audio)

        try library.keepAudio(true, of: [draft].flatMap(\.unsavedRecordings))

        let kept = try #require(library.recordings(of: part.id).first)
        #expect(kept.id == draft.recording?.id)
        #expect(library.audio(of: kept.id) == audio)
    }

    @Test func `discarding Practice Entry Drafts and their audio deletes the Recordings made for them`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addGuitarPart()
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")
        let older = try #require(try library.addRecording(audio: Data("last week".utf8), to: wonderwall.id))
        var guitar = PracticeEntryDraft(part: wonderwall)
        var piano = PracticeEntryDraft(part: yesterday)
        try library.replaceRecording(of: &guitar, withAudio: audio)
        try library.replaceRecording(of: &piano, withAudio: Data("scales".utf8))

        try library.keepAudio(false, of: [guitar, piano].flatMap(\.unsavedRecordings))

        #expect(library.recordings(of: wonderwall.id).map(\.id) == [older.id])
        #expect(library.recordings(of: yesterday.id).isEmpty)
    }

    @Test func `a Recording picked from the Part's Recordings is never at stake when a draft lets go of it`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let existing = try #require(try library.addRecording(audio: audio, to: part.id))
        var draft = PracticeEntryDraft(part: part)

        draft.replaceRecording(with: existing)
        #expect(draft.recording == existing)
        #expect(draft.unsavedRecordings.isEmpty)

        let removed = draft.replaceRecording(with: nil)
        #expect(removed.isEmpty)
        #expect(draft.recording == nil)
        #expect(library.recordings(of: part.id) == [existing])
    }

    @Test func `removing or replacing a Recording made for a draft puts that Recording at stake`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addGuitarPart()
        let existing = try #require(try library.addRecording(audio: Data("last week".utf8), to: part.id))
        var draft = PracticeEntryDraft(part: part)
        try library.replaceRecording(of: &draft, withAudio: Data("first go".utf8))
        let first = try #require(draft.recording)
        clock.advance(days: 1)

        let rerecorded = try library.replaceRecording(of: &draft, withAudio: audio)
        let second = try #require(draft.recording)
        #expect(rerecorded == [first])
        #expect(draft.unsavedRecordings == [second])

        let picked = draft.replaceRecording(with: existing)
        #expect(picked == [second])
        #expect(draft.unsavedRecordings.isEmpty)

        try library.replaceRecording(of: &draft, withAudio: Data("third go".utf8))
        let third = try #require(draft.recording)
        let removed = draft.replaceRecording(with: nil)
        #expect(removed == [third])
        #expect(draft.recording == nil)
    }

    @Test func `saving a Practice Entry keeps the Recording made for its draft`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        var draft = PracticeEntryDraft(part: part, rating: .good)
        try library.replaceRecording(of: &draft, withAudio: audio)
        let made = try #require(draft.recording)

        let session = try #require(try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 1800,
            note: "",
            drafts: [draft],
        ))

        let entry = try #require(library.practiceEntries(in: session.id).first)
        #expect(entry.recording?.id == made.id)
        #expect(library.recordings(of: part.id).map(\.id) == [made.id])
        #expect(library.audio(of: made.id) == audio)
    }
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        let song = try addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try addInstrument(name: "Guitar")
        return try #require(try addPart(to: song.id, instrument: guitar.id))
    }

    func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try addSong(title: title, artist: "")
        let instrument = try addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id))
    }
}
