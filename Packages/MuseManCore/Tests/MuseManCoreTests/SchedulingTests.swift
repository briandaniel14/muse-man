import Foundation
import MuseManCore
import Testing

struct SchedulingTests {
    @Test func `a Part rated Easy isn't Due a day later, but is once its interval has passed`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()

        try library.review(part, .easy, on: 0)

        clock.advance(days: 1)
        #expect(library.practiceNext().isEmpty)
        clock.advance(days: 14)
        #expect(library.practiceNext().isEmpty)
        clock.advance(days: 1)
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `practising on the due date with Good pushes the next review further out each time`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        let intervals = try library.intervals(for: part, rating: [.good, .good, .good, .good, .good, .good])

        #expect(intervals == [3, 11, 35, 101, 269, 669])
    }

    @Test func `forgetting a Part with Again brings it back sooner, then it recovers`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        let intervals = try library.intervals(for: part, rating: [.good, .good, .good, .again, .good, .good])

        #expect(intervals == [3, 11, 35, 4, 11, 29])
    }

    @Test func `a Hard Part comes back sooner and an Easy one later`() throws {
        let library = PracticeLibrary.inMemory()
        var dueOffsets: [Int?] = []

        for rating in Rating.allCases {
            let part = try library.addLearningPart(song: rating.title)
            try library.review(part, rating, on: 0)
            try dueOffsets.append(library.dueOffset(of: part))
        }

        #expect(dueOffsets == [1, 1, 3, 16])
    }

    @Test func `a Part rated Again doesn't return to Practice Next until the next day`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()

        try library.review(part, .again, on: 0)

        #expect(library.practiceNext().isEmpty)
        clock.advance(days: 1)
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `practising Hard on the due date keeps the interval short`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        let intervals = try library.intervals(for: part, rating: [.hard, .hard, .hard, .hard])

        #expect(intervals == [1, 2, 3, 4])
    }

    @Test func `a Part kept Easy is never scheduled more than 36,500 days out`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        let intervals = try library.intervals(for: part, rating: Array(repeating: .easy, count: 30))

        #expect(Array(intervals.prefix(4)) == [16, 150, 1252, 9305])
        #expect(intervals.last == 36500)
        #expect(intervals.allSatisfy { $0 <= 36500 })
    }

    @Test func `practising early grows the interval less than practising on the due date`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        try library.review(part, .good, on: 0)
        try library.review(part, .good, on: 1)
        #expect(try library.dueOffset(of: part) == 7)
        try library.review(part, .good, on: 7)
        #expect(try library.dueOffset(of: part) == 27)
    }

    @Test func `practising late grows the interval more than practising on the due date`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addLearningPart()

        try library.review(part, .good, on: 0)
        try library.review(part, .good, on: 13)

        #expect(try library.dueOffset(of: part) == 41)
    }

    @Test func `several Practice Entries for a Part on one day count as one review`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()

        try library.review(part, .good, on: 0, hour: 8)
        clock.now += 60
        try library.review(part, .good, on: 0, hour: 19)

        #expect(try library.dueOffset(of: part) == 3)
    }

    @Test func `the latest Practice Session's Rating that day wins, whatever order they were logged in`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()

        try library.review(part, .again, on: 0, hour: 19)
        clock.now += 60
        try library.review(part, .easy, on: 0, hour: 8)

        #expect(try library.dueOffset(of: part) == 1)
    }

    @Test func `unrated Practice Entries don't change when a Part is next Due`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()

        try library.review(part, .easy, on: 0, hour: 8)
        clock.now += 60
        try library.review(part, nil, on: 0, hour: 19)
        try library.review(part, nil, on: 5)

        #expect(try library.dueOffset(of: part) == 16)
    }

    @Test func `a Part whose only Practice Entries have no Rating is Due as if never reviewed`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addLearningPart()
        clock.advance(days: 3)

        try library.review(part, nil, on: 3)

        #expect(try library.dueOffset(of: part) == 3)
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `switching Practice Next back on makes Parts with no rated Practice Entries Due today`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let unrated = try library.addLearningPart(song: "Wonderwall")
        let unpractised = try library.addLearningPart(song: "Yesterday")
        let rated = try library.addLearningPart(song: "Hey Jude")
        try library.review(unrated, nil, on: 0)
        try library.review(rated, .easy, on: 0)
        clock.advance(days: 5)

        try library.makeUnratedPartsDueToday()

        #expect(try library.dueOffset(of: unrated) == 5)
        #expect(try library.dueOffset(of: unpractised) == 5)
        #expect(try library.dueOffset(of: rated) == 16)
    }

    @Test func `switching Practice Next back on leaves Want to learn Parts not Due`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let song = try library.addSong(title: "Wonderwall", artist: "")
        let instrument = try library.addInstrument(name: "Guitar")
        let part = try #require(try library.addPart(to: song.id, instrument: instrument.id))

        try library.makeUnratedPartsDueToday()

        #expect(library.part(id: part.id)?.dueDate == nil)
    }

    @Test func `within a Practice Session the Practice Entry logged last wins`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let first = try library.addLearningPart(song: "Wonderwall")
        let second = try library.addLearningPart(song: "Yesterday")
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)

        try library.addPracticeEntry(to: session.id, part: first.id, rating: .easy)
        try library.addPracticeEntry(to: session.id, part: second.id, rating: .again)
        clock.now += 60
        try library.addPracticeEntry(to: session.id, part: first.id, rating: .again)
        try library.addPracticeEntry(to: session.id, part: second.id, rating: .easy)

        #expect(try library.dueOffset(of: first) == 1)
        #expect(try library.dueOffset(of: second) == 16)
    }
}

private func day(_ offset: Int) -> Date? {
    Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: TestClock.start))
}

private extension PracticeLibrary {
    func addLearningPart(song title: String = "Wonderwall") throws -> Part {
        let song = try addSong(title: title, artist: "")
        let instrument = try instruments().first ?? addInstrument(name: "Guitar")
        var part = try #require(try addPart(to: song.id, instrument: instrument.id))
        part.status = .learning
        try updatePart(part)
        return part
    }

    func review(_ part: Part, _ rating: Rating?, on offset: Int, hour: Int = 12) throws {
        let start = try #require(day(offset).flatMap { Calendar.current.date(byAdding: .hour, value: hour, to: $0) })
        let session = try addPracticeSession(startDate: start, duration: 30 * 60)
        try addPracticeEntry(to: session.id, part: part.id, rating: rating)
    }

    func intervals(for part: Part, rating ratings: [Rating]) throws -> [Int] {
        var intervals: [Int] = []
        var offset = 0
        for rating in ratings {
            try review(part, rating, on: offset)
            let due = try #require(try dueOffset(of: part))
            intervals.append(due - offset)
            offset = due
        }
        return intervals
    }

    func dueOffset(of part: Part) throws -> Int? {
        let due = try #require(self.part(id: part.id)?.dueDate)
        let start = try #require(day(0))
        return Calendar.current.dateComponents([.day], from: start, to: due).day
    }
}
