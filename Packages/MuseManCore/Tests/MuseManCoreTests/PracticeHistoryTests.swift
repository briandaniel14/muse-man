import Foundation
import MuseManCore
import Testing

struct PracticeHistoryTests {
    @Test func `a Part's practice history lists its Practice Entries newest first, by Practice Session day`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let monday = try library.addPracticeSession(startDate: #require(time(2026, 1, 1, hour: 20)), duration: 1800)
        let friday = try library.addPracticeSession(startDate: #require(time(2026, 1, 4, hour: 9)), duration: 1800)
        try library.addPracticeEntry(to: friday.id, part: guitar.id, rating: .easy, note: "clean changes")
        clock.now += 60
        try library.addPracticeEntry(to: monday.id, part: guitar.id, rating: .hard, note: "slow")
        try library.addPracticeEntry(to: monday.id, part: piano.id, rating: .good)

        let history = library.practiceEntries(of: guitar.id)

        #expect(history.map(\.rating) == [.easy, .hard])
        #expect(history.map(\.note) == ["clean changes", "slow"])
        #expect(history.map(\.day) == [day(2026, 1, 4), day(2026, 1, 1)])
    }

    @Test func `editing a Practice Entry's Rating recomputes its Part's due date and keeps the new note`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        var entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good))
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 8))

        entry.rating = .again
        entry.note = "lost the bridge"
        try library.updatePracticeEntry(entry)

        let edited = try #require(library.practiceEntries(of: part.id).first)
        #expect(edited.rating == .again)
        #expect(edited.note == "lost the bridge")
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 6))
    }

    @Test func `deleting a Practice Entry recomputes its Part's due date from the rest`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let earlier = try library.addPracticeSession(startDate: #require(time(2026, 1, 3, hour: 9)), duration: 1800)
        let later = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: earlier.id, part: part.id, rating: .easy)
        let mistake = try #require(try library.addPracticeEntry(to: later.id, part: part.id, rating: .again))

        try library.deletePracticeEntry(id: mistake.id)

        #expect(library.practiceEntries(of: part.id).map(\.rating) == [.easy])
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 19))
    }

    @Test func `deleting every Practice Entry for a Part makes it Due today`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .easy))
        clock.advance(days: 2)

        try library.deletePracticeEntry(id: entry.id)

        #expect(library.practiceEntries(of: part.id).isEmpty)
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 7))
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `deleting the last Practice Entry of a Practice Session deletes the Practice Session`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let first = try #require(try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good))
        let last = try #require(try library.addPracticeEntry(to: session.id, part: piano.id, rating: .good))

        try library.deletePracticeEntry(id: first.id)
        #expect(library.practiceSessions().map(\.id) == [session.id])

        try library.deletePracticeEntry(id: last.id)
        #expect(library.practiceSession(id: session.id) == nil)
        #expect(library.practiceSessions().isEmpty)
    }

    @Test func `deleting the only Practice Entry of a finished Practice Session would delete it`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good))

        #expect(library.deletingPracticeEntryDeletesItsSession(id: entry.id))
    }

    @Test func `deleting one of several Practice Entries would keep the Practice Session`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good))
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .good)

        #expect(!library.deletingPracticeEntryDeletesItsSession(id: entry.id))
    }

    @Test func `deleting the only Practice Entry of a running Practice Session would keep it`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.startPracticeSession()
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good))

        #expect(!library.deletingPracticeEntryDeletesItsSession(id: entry.id))
    }

    @Test func `deleting the last Practice Entry of a running Practice Session keeps it running`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let session = try library.startPracticeSession()
        let entry = try #require(try library.addPracticeEntry(to: session.id, part: part.id, rating: .good))

        try library.deletePracticeEntry(id: entry.id)

        #expect(library.runningPracticeSession()?.id == session.id)
        #expect(library.practiceEntries(in: session.id).isEmpty)
    }

    @Test func `editing a Practice Session keeps its new start date, duration and note`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        var session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good)
        let start = try #require(time(2026, 1, 5, hour: 7, minute: 15))
        let duration: TimeInterval = 50 * 60

        session.startDate = start
        session.duration = duration
        session.note = "before work"
        try library.updatePracticeSession(session)

        let edited = try #require(library.practiceSession(id: session.id))
        #expect(edited.startDate == start)
        #expect(edited.duration == duration)
        #expect(edited.note == "before work")
    }

    @Test func `editing a running Practice Session that has since finished keeps it finished`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        var session = try library.startPracticeSession()
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good)
        clock.now += 20 * 60
        try library.finishPracticeSession(id: session.id)

        session.note = "fingers sore"
        try library.updatePracticeSession(session)

        let duration: TimeInterval = 20 * 60
        #expect(library.practiceSession(id: session.id)?.duration == duration)
        #expect(library.practiceSession(id: session.id)?.note == "fingers sore")
        #expect(library.runningPracticeSession() == nil)
    }

    @Test func `a new Practice Session start date moves its Practice Entries to that day and reschedules`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let earlier = try library.addPracticeSession(startDate: #require(time(2026, 1, 2, hour: 8)), duration: 1800)
        var session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: earlier.id, part: guitar.id, rating: .again)
        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good)
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .good)
        #expect(library.part(id: piano.id)?.dueDate == day(2026, 1, 8))

        session.startDate = try #require(time(2026, 1, 2, hour: 19))
        try library.updatePracticeSession(session)

        #expect(library.practiceEntries(in: session.id).map(\.day) == [day(2026, 1, 2), day(2026, 1, 2)])
        #expect(library.part(id: piano.id)?.dueDate == day(2026, 1, 5))
        #expect(library.part(id: guitar.id)?.dueDate == day(2026, 1, 5))
    }

    @Test func `deleting a Practice Session deletes its Practice Entries, keeps Recordings and reschedules`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let earlier = try library.addPracticeSession(startDate: #require(time(2026, 1, 3, hour: 9)), duration: 1800)
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: earlier.id, part: part.id, rating: .easy)
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .again)
        try library.addRecording(audio: Data("take".utf8), to: part.id)

        try library.deletePracticeSession(id: session.id)

        #expect(library.practiceSessions().map(\.id) == [earlier.id])
        #expect(library.practiceEntries(in: session.id).isEmpty)
        #expect(library.practiceEntries(of: part.id).map(\.rating) == [.easy])
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 19))
        #expect(library.recordings(of: part.id).count == 1)
    }

    @Test func `deleting a Part deletes its Practice Entries and the finished Practice Sessions left empty`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let mixed = try library.addPracticeSession(startDate: #require(time(2026, 1, 3, hour: 9)), duration: 1800)
        let guitarOnly = try library.addPracticeSession(startDate: #require(time(2026, 1, 4, hour: 9)), duration: 1800)
        let running = try library.startPracticeSession()
        try library.addPracticeEntry(to: mixed.id, part: guitar.id, rating: .good)
        let pianoEntry = try #require(try library.addPracticeEntry(to: mixed.id, part: piano.id, rating: .hard))
        try library.addPracticeEntry(to: guitarOnly.id, part: guitar.id, rating: .good)
        try library.addPracticeEntry(to: running.id, part: guitar.id, rating: .good)

        try library.deletePart(id: guitar.id)

        #expect(library.practiceEntries(in: mixed.id).map(\.id) == [pianoEntry.id])
        #expect(library.practiceSession(id: guitarOnly.id) == nil)
        #expect(library.runningPracticeSession()?.id == running.id)
        #expect(library.practiceEntries(in: running.id).isEmpty)
        #expect(library.practiceSessions().map(\.id) == [running.id, mixed.id])
    }

    @Test func `deleting a Song deletes its Parts' Practice Entries`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good)
        let pianoEntry = try #require(try library.addPracticeEntry(to: session.id, part: piano.id, rating: .hard))

        try library.deleteSong(id: guitar.song.id)

        #expect(library.practiceEntries(in: session.id).map(\.id) == [pianoEntry.id])
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
}
