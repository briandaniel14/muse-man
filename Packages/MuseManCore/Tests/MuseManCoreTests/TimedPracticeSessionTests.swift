import Foundation
import MuseManCore
import Testing

struct TimedPracticeSessionTests {
    @Test func `a started Practice Session is saved at once, running with no duration`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)

        let session = try library.startPracticeSession()

        let running = try #require(library.runningPracticeSession())
        #expect(running.id == session.id)
        #expect(running.startDate == TestClock.start)
        #expect(running.duration == nil)
        #expect(library.practiceSessions().map(\.id) == [session.id])
    }

    @Test func `starting a Practice Session while one is running resumes it`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let session = try library.startPracticeSession()
        clock.now += 15 * 60

        let resumed = try library.startPracticeSession()

        #expect(resumed.id == session.id)
        #expect(resumed.startDate == TestClock.start)
        #expect(library.practiceSessions().map(\.id) == [session.id])
    }

    @Test func `finishing a running Practice Session records the elapsed duration`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addGuitarPart()
        let session = try library.startPracticeSession()
        clock.now += 10 * 60
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good)
        clock.now += 25 * 60

        try library.finishPracticeSession(id: session.id)

        let finished = try #require(library.practiceSession(id: session.id))
        let duration: TimeInterval = 35 * 60
        #expect(finished.duration == duration)
        #expect(finished.startDate == TestClock.start)
        #expect(library.runningPracticeSession() == nil)
    }

    @Test func `an empty running Practice Session is kept across launches and is still running`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let start = TestClock.start
        try PracticeLibrary(container: PersistentStore.container(storeURL: storeURL), now: { start })
            .startPracticeSession()

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        let running = try #require(relaunched.runningPracticeSession())
        #expect(running.startDate == start)
        #expect(running.duration == nil)
        #expect(relaunched.practiceEntries(in: running.id).isEmpty)
    }

    @Test func `a running Practice Session finished with no Practice Entries is deleted`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let session = try library.startPracticeSession()
        clock.now += 5 * 60

        try library.finishPracticeSession(id: session.id)

        #expect(library.practiceSession(id: session.id) == nil)
        #expect(library.runningPracticeSession() == nil)
        #expect(library.practiceSessions().isEmpty)
    }

    @Test func `a running Practice Session takes Due Parts off Practice Next as they are logged`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let guitar = try library.addGuitarPart()
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        try library.move(guitar, to: .learning)
        try library.move(piano, to: .learned)
        let session = try library.startPracticeSession()

        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good)
        #expect(library.practiceNext().map(\.id) == [piano.id])

        clock.now += 60
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .easy)
        #expect(library.practiceNext().isEmpty)
        #expect(library.runningPracticeSession()?.id == session.id)
    }

    @Test func `a timed Practice Session has its Due Parts to practise, most overdue first`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let guitar = try library.addGuitarPart()
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        try library.addPart(song: "Hey Jude", instrument: "Bass")
        try library.move(piano, to: .learned)
        clock.advance(days: 1)
        try library.move(guitar, to: .learning)
        let session = try library.startPracticeSession()

        let toPractise = library.partsToPractise(in: session.id, picked: [])

        #expect(toPractise.map(\.id) == [piano.id, guitar.id])
    }

    @Test func `picked Parts are to practise after the Due Parts, each once`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addGuitarPart()
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let bass = try library.addPart(song: "Hey Jude", instrument: "Bass")
        try library.move(guitar, to: .learning)
        let session = try library.startPracticeSession()

        let toPractise = library.partsToPractise(in: session.id, picked: [bass, guitar, piano])

        #expect(toPractise.map(\.id) == [guitar.id, bass.id, piano.id])
    }

    @Test func `a Part logged in a timed Practice Session is no longer to practise in it`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addGuitarPart()
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let bass = try library.addPart(song: "Hey Jude", instrument: "Bass")
        try library.move(guitar, to: .learning)
        try library.move(piano, to: .learning)
        let session = try library.startPracticeSession()

        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .again)
        try library.addPracticeEntry(to: session.id, part: bass.id, rating: .good)

        #expect(library.partsToPractise(in: session.id, picked: [bass]).map(\.id) == [piano.id])
    }

    @Test func `a rated Practice Entry Draft is logged with its trimmed note and Recording`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addGuitarPart()
        let recording = try #require(try library.addRecording(audio: Data("take one".utf8), to: guitar.id))
        let session = try library.startPracticeSession()
        let draft = PracticeEntryDraft(part: guitar, rating: .hard, note: "  chorus \n", recording: recording)

        try library.logPracticeEntry(draft, in: session.id)

        let entries = library.practiceEntries(in: session.id)
        #expect(entries.map(\.partIdentifier) == [guitar.identifier])
        #expect(entries.first?.rating == .hard)
        #expect(entries.first?.note == "chorus")
        #expect(entries.first?.recordingID == recording.identifier)
        #expect(library.partsToPractise(in: session.id, picked: [guitar]).isEmpty)
    }

    @Test func `a Practice Entry Draft with no Rating is not logged`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addGuitarPart()
        let session = try library.startPracticeSession()

        let entry = try library.logPracticeEntry(PracticeEntryDraft(part: guitar, note: "warm-up"), in: session.id)

        #expect(entry == nil)
        #expect(library.practiceEntries(in: session.id).isEmpty)
        #expect(library.partsToPractise(in: session.id, picked: [guitar]).map(\.id) == [guitar.id])
    }

    @Test func `a Part rated after midnight in a session started before it is no longer to practise`() throws {
        let beforeMidnight = DateComponents(year: 2026, month: 1, day: 5, hour: 23, minute: 50)
        let clock = try TestClock(now: #require(Calendar.current.date(from: beforeMidnight)))
        let library = PracticeLibrary.inMemory(clock: clock)
        let guitar = try library.addGuitarPart()
        try library.move(guitar, to: .learning)
        let session = try library.startPracticeSession()
        clock.now += 20 * 60

        try library.logPracticeEntry(PracticeEntryDraft(part: guitar, rating: .again), in: session.id)

        #expect(library.practiceNext().map(\.id) == [guitar.id])
        #expect(library.partsToPractise(in: session.id, picked: []).isEmpty)
    }
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        try addPart(song: "Wonderwall", instrument: "Guitar")
    }

    @discardableResult func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try addSong(title: title, artist: "")
        let instrument = try addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id))
    }

    func move(_ part: Part, to status: Part.Status) throws {
        var part = try #require(self.part(id: part.id))
        part.status = status
        try updatePart(part)
    }
}
