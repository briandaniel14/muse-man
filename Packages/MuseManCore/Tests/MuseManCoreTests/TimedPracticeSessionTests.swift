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
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        try addPart(song: "Wonderwall", instrument: "Guitar")
    }

    func addPart(song title: String, instrument name: String) throws -> Part {
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
