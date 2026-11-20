import Foundation
import MuseManCore
import Testing

struct PracticeNextTests {
    @Test func `a Part moved to Learning for the first time is in Practice Next straight away`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")

        try library.move(part, to: .learning)

        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `a Part moved straight from Want to learn to Learned is Due today`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        clock.advance(days: 2)

        try library.move(part, to: .learned)

        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 7))
        #expect(library.practiceNext().map(\.id) == [part.id])
    }

    @Test func `a Want to learn Part is never in Practice Next, even with a due date in the past`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        try library.move(part, to: .learning)
        clock.advance(days: 10)

        try library.move(part, to: .wantToLearn)

        #expect(library.practiceNext().isEmpty)
        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 5))
    }

    @Test func `a Part never moved out of Want to learn is not in Practice Next`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        try library.addPart(song: "Wonderwall", instrument: "Guitar")

        clock.advance(days: 30)

        #expect(library.practiceNext().isEmpty)
    }

    @Test func `the Practice Next list holds Learning and Learned Parts, most overdue first`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let blackbird = try library.addPart(song: "Blackbird", instrument: "Guitar")
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar", label: "Lead")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")

        try library.move(wonderwall, to: .learning)
        try library.move(wonderwall, to: .learned)
        clock.advance(days: 1)
        try library.move(yesterday, to: .learning)
        clock.advance(days: 1)
        try library.move(blackbird, to: .learning)

        let practiceNext = library.practiceNext()
        #expect(practiceNext.map(\.song.title) == ["Wonderwall", "Yesterday", "Blackbird"])
        #expect(practiceNext.map(\.status) == [.learned, .learning, .learning])
    }

    @Test func `moving the clock forward to a Part's due date makes it Due`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        clock.advance(days: 3)
        try library.move(part, to: .learning)

        clock.now = try #require(time(2026, 1, 5, hour: 9))
        #expect(library.practiceNext().isEmpty)
        clock.now = try #require(time(2026, 1, 7, hour: 23, minute: 59))
        #expect(library.practiceNext().isEmpty)
        clock.now = try #require(time(2026, 1, 8, hour: 0, minute: 1))
        #expect(library.practiceNext().map(\.id) == [part.id])
        clock.advance(days: 5)
        #expect(library.practiceNext().map(\.id) == [part.id])
    }
}

private func time(_ year: Int, _ month: Int, _ day: Int, hour: Int, minute: Int = 0) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))
}

private func day(_ year: Int, _ month: Int, _ day: Int) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
}

private extension PracticeLibrary {
    @discardableResult func addPart(song title: String, instrument name: String, label: String? = nil) throws -> Part {
        let song = try songs().first { $0.title == title } ?? addSong(title: title, artist: "")
        let instrument = try instruments().first { $0.name == name } ?? addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id, label: label))
    }

    func move(_ part: Part, to status: Part.Status) throws {
        var part = try #require(self.part(id: part.id))
        part.status = status
        try updatePart(part)
    }
}
