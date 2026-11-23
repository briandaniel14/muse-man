import Foundation
import MuseManCore
import Testing

struct EntryRecordingTests {
    let audio = Data("tonight's recording".utf8)

    @Test func `a Recording made while logging a Practice Entry plays from the Part's practice history`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let recording = try #require(try library.addRecording(audio: audio, to: part.id))

        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good, recordingID: recording.identifier)

        let entry = try #require(library.practiceEntries(of: part.id).first)
        let attached = try #require(entry.recording)
        #expect(attached.id == recording.id)
        #expect(library.audio(of: attached.id) == audio)
        #expect(library.recordings(of: part.id).map(\.id) == [recording.id])
    }

    @Test func `editing a Practice Entry attaches one of the Part's existing Recordings, or detaches it`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addGuitarPart()
        let older = try #require(try library.addRecording(audio: Data("monday".utf8), to: part.id))
        clock.advance(days: 1)
        try library.addRecording(audio: audio, to: part.id)
        let session = try library.addPracticeSession(startDate: clock.now, duration: 1800)
        var entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .hard))
        #expect(entry.recording == nil)

        entry.recording = older
        try library.updatePracticeEntry(entry)
        #expect(library.practiceEntries(of: part.id).first?.recording?.id == older.id)

        entry.recording = nil
        try library.updatePracticeEntry(entry)
        #expect(library.practiceEntries(of: part.id).first?.recording == nil)
        #expect(library.recordings(of: part.id).count == 2)
    }

    @Test func `deleting a Practice Entry keeps its Recording on the Part`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let recording = try #require(try library.addRecording(audio: audio, to: part.id))
        let entry = try #require(try library.addPracticeEntry(
            to: session.id,
            part: part.id,
            rating: .good,
            recordingID: recording.identifier,
        ))

        try library.deletePracticeEntry(id: entry.id)

        #expect(library.practiceEntries(of: part.id).isEmpty)
        #expect(library.recordings(of: part.id).map(\.id) == [recording.id])
        #expect(library.audio(of: recording.id) == audio)
    }

    @Test func `deleting a Practice Session keeps its Practice Entries' Recordings on their Parts`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let session = try library.startPracticeSession()
        let recording = try #require(try library.addRecording(audio: audio, to: part.id))
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .easy, recordingID: recording.identifier)

        try library.deletePracticeSession(id: session.id)

        #expect(library.practiceSessions().isEmpty)
        #expect(library.recordings(of: part.id).map(\.id) == [recording.id])
        #expect(library.audio(of: recording.id) == audio)
    }

    @Test func `a Practice Entry whose Recording was deleted still shows, without the Recording`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let recording = try #require(try library.addRecording(audio: audio, to: part.id))
        let entry = try #require(try library.addPracticeEntry(
            to: session.id,
            part: part.id,
            rating: .hard,
            note: "rushed the chorus",
            recordingID: recording.identifier,
        ))

        try library.deleteRecording(id: recording.id)

        let shown = try #require(library.practiceEntries(of: part.id).first)
        #expect(shown.id == entry.id)
        #expect(shown.note == "rushed the chorus")
        #expect(library.practiceEntries(in: session.id).map(\.id) == [entry.id])
        #expect(shown.part?.id == part.id)
        #expect(shown.recording == nil)
    }
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        let song = try addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try addInstrument(name: "Guitar")
        return try #require(try addPart(to: song.id, instrument: guitar.id))
    }
}
