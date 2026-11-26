import Foundation
import MuseManCore
import Testing

struct PracticeSessionTests {
    @Test func `a Practice Session logged after the fact keeps its start date, duration and note`() throws {
        let library = PracticeLibrary.inMemory()
        let start = try #require(time(2026, 1, 3, hour: 18, minute: 30))
        let duration: TimeInterval = 45 * 60

        let session = try library.addPracticeSession(startDate: start, duration: duration, note: "tired, fingers sore")

        let logged = try #require(library.practiceSession(id: session.id))
        #expect(logged.startDate == start)
        #expect(logged.duration == duration)
        #expect(logged.note == "tired, fingers sore")
        #expect(library.practiceSessions().map(\.id) == [session.id])
    }

    @Test func `a Practice Session holds Practice Entries for Parts on different Instruments`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)

        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .hard, note: "chorus strumming")
        clock.now += 60
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .easy)

        let entries = library.practiceEntries(in: session.id)
        #expect(entries.map(\.partIdentifier) == [guitar.identifier, piano.identifier])
        #expect(entries.map(\.rating) == [.hard, .easy])
        #expect(entries.map(\.note) == ["chorus strumming", ""])
        let instruments = entries.compactMap(\.part?.instrument.name)
        #expect(instruments == ["Guitar", "Piano"])
    }

    @Test func `several Practice Sessions on the same day are kept separate`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let morning = try library.addPracticeSession(
            startDate: #require(time(2026, 1, 5, hour: 8)),
            duration: 20 * 60,
        )
        let evening = try library.addPracticeSession(
            startDate: #require(time(2026, 1, 5, hour: 19)),
            duration: 40 * 60,
            note: "after dinner",
        )

        try library.addPracticeEntry(to: morning.id, part: part.id, rating: .again)
        try library.addPracticeEntry(to: evening.id, part: part.id, rating: .good)

        #expect(library.practiceSessions().map(\.id) == [evening.id, morning.id])
        #expect(library.practiceEntries(in: morning.id).map(\.rating) == [.again])
        #expect(library.practiceEntries(in: evening.id).map(\.rating) == [.good])
    }

    @Test func `a Due Part leaves Practice Next once a Practice Entry is logged for it, until the next day`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")
        try library.move(wonderwall, to: .learning)
        try library.move(yesterday, to: .learned)
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)

        try library.addPracticeEntry(to: session.id, part: wonderwall.id, rating: .again)

        #expect(library.practiceNext().map(\.id) == [yesterday.id])
        #expect(library.part(id: wonderwall.id)?.dueDate == day(2026, 1, 6))
        clock.advance(days: 1)
        #expect(library.practiceNext().map(\.id) == [yesterday.id, wonderwall.id])
    }

    @Test func `logging a Practice Entry for a Want to learn Part moves it to Learning`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 30 * 60)

        try library.addPracticeEntry(to: session.id, part: part.id, rating: .hard)

        let logged = try #require(library.part(id: part.id))
        #expect(logged.status == .learning)
        #expect(logged.dueDate == day(2026, 1, 6))
    }

    @Test func `a Practice Entry is reviewed on its Practice Session's start date, not the day it was logged`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        try library.move(part, to: .learning)
        let session = try library.addPracticeSession(
            startDate: #require(time(2026, 1, 1, hour: 20)),
            duration: 60 * 60,
        )

        try library.addPracticeEntry(to: session.id, part: part.id, rating: .again)

        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 2))
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `a renamed Practice Session keeps its trimmed name`() throws {
        let library = PracticeLibrary.inMemory()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 30 * 60)
        #expect(library.practiceSession(id: session.id)?.name == nil)

        try library.renamePracticeSession(id: session.id, to: "  Scales warm-up ")

        #expect(library.practiceSessions().map(\.name) == ["Scales warm-up"])
        #expect(library.practiceSession(id: session.id)?.startDate == TestClock.start)
    }

    @Test func `clearing a Practice Session's name leaves it unnamed`() throws {
        let library = PracticeLibrary.inMemory()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 30 * 60)
        try library.renamePracticeSession(id: session.id, to: "Scales warm-up")

        try library.renamePracticeSession(id: session.id, to: " ")

        #expect(library.practiceSession(id: session.id)?.name == nil)
    }

    @Test func `a Practice Session finished with no Practice Entries is deleted`() throws {
        let library = PracticeLibrary.inMemory()
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 10 * 60)

        try library.finishPracticeSession(id: session.id)

        #expect(library.practiceSession(id: session.id) == nil)
        #expect(library.practiceSessions().isEmpty)
    }

    @Test func `a Practice Session finished with Practice Entries is kept`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 10 * 60)
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good)

        try library.finishPracticeSession(id: session.id)

        #expect(library.practiceSessions().map(\.id) == [session.id])
        #expect(library.practiceEntries(in: session.id).count == 1)
    }

    @Test func `a Practice Entry comes with its Part, and none can be added once the Part is deleted`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 10 * 60)
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good))
        #expect(entry.part?.id == part.id)

        try library.deletePart(id: part.id)

        #expect(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good) == nil)
    }
}

private func time(_ year: Int, _ month: Int, _ day: Int, hour: Int, minute: Int = 0) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))
}

private func day(_ year: Int, _ month: Int, _ day: Int) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
}

private extension PracticeLibrary {
    @discardableResult func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try songs().first { $0.title == title } ?? addSong(title: title, artist: "")
        let instrument = try instruments().first { $0.name == name } ?? addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id))
    }

    func move(_ part: Part, to status: Part.Status) throws {
        var part = try #require(self.part(id: part.id))
        part.status = status
        try updatePart(part)
    }
}
