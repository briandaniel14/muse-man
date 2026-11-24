import CoreData
import MuseManCore
import Testing

struct LogPracticeSessionTests {
    @Test func `logging a Practice Session saves its Practice Entries, ratings, trimmed notes and Recordings`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")
        let recording = try #require(try library.addRecording(audio: Data("take one".utf8), to: wonderwall.id))
        let start = try #require(time(2026, 1, 5, hour: 9))
        let duration: TimeInterval = 45 * 60
        let drafts = [
            PracticeEntryDraft(
                part: wonderwall,
                rating: .hard,
                note: "  chorus strumming \n",
                recording: recording,
            ),
            PracticeEntryDraft(part: yesterday, rating: .easy),
        ]

        let session = try #require(try library.logPracticeSession(
            startDate: start,
            duration: duration,
            note: "\n tired, fingers sore  ",
            drafts: drafts,
            isPracticeNextOn: true,
        ))

        let logged = try #require(library.practiceSession(id: session.id))
        #expect(logged.startDate == start)
        #expect(logged.duration == duration)
        #expect(logged.note == "tired, fingers sore")
        let entries = library.practiceEntries(in: session.id)
        let guitar = try #require(entries.first { $0.partIdentifier == wonderwall.identifier })
        let piano = try #require(entries.first { $0.partIdentifier == yesterday.identifier })
        #expect(entries.count == 2)
        #expect(guitar.rating == .hard)
        #expect(guitar.note == "chorus strumming")
        #expect(guitar.recordingID == recording.identifier)
        #expect(piano.rating == .easy)
        #expect(piano.note == "")
        #expect(piano.recordingID == nil)
    }

    @Test func `logging a Practice Session moves its Want to learn Parts to Learning and schedules them`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")

        try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 30 * 60,
            note: "",
            drafts: [PracticeEntryDraft(part: part, rating: .hard)],
            isPracticeNextOn: true,
        )

        let logged = try #require(library.part(id: part.id))
        #expect(logged.status == .learning)
        #expect(logged.dueDate == day(2026, 1, 6))
    }

    @Test func `with Practice Next switched off, an unrated draft is logged as a Practice Entry without a Rating`(
    ) throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")

        let session = try #require(try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 30 * 60,
            note: "",
            drafts: [PracticeEntryDraft(part: wonderwall, rating: .hard), PracticeEntryDraft(part: yesterday)],
            isPracticeNextOn: false,
        ))

        let entries = library.practiceEntries(in: session.id)
        let ratings = Dictionary(uniqueKeysWithValues: entries.map { ($0.partIdentifier, $0.rating) })
        #expect(ratings == [wonderwall.identifier: .hard, yesterday.identifier: nil])
    }

    @Test func `a Practice Session with an unrated draft is not ready to save, as the screen still asks for a Rating`(
    ) throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let drafts = [PracticeEntryDraft(part: part)]

        #expect(!library.canLogPracticeSession(duration: 60, drafts: drafts, isPracticeNextOn: true))
    }

    @Test func `with Practice Next on, a Practice Session with an unrated draft is not logged`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")

        let session = try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 30 * 60,
            note: "",
            drafts: [PracticeEntryDraft(part: wonderwall, rating: .hard), PracticeEntryDraft(part: yesterday)],
            isPracticeNextOn: true,
        )

        #expect(session == nil)
        #expect(library.practiceSessions().isEmpty)
        #expect(library.practiceEntries(of: wonderwall.id).isEmpty)
    }

    @Test func `with Practice Next switched off, a Practice Session of unrated drafts is ready to save`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let drafts = [PracticeEntryDraft(part: part)]

        #expect(library.canLogPracticeSession(duration: 60, drafts: drafts, isPracticeNextOn: false))
        #expect(!library.canLogPracticeSession(duration: 60, drafts: [], isPracticeNextOn: false))
    }

    @Test(arguments: [
        (minutes: 0, ratings: [Rating.good]),
        (minutes: 30, ratings: []),
    ])
    func `a Practice Session with no duration or no Practice Entry Drafts is not ready to save`(
        minutes: Int,
        ratings: [Rating?],
    ) throws {
        let library = PracticeLibrary.inMemory()
        let duration = TimeInterval(minutes * 60)
        let drafts = try ratings.enumerated().map { index, rating in
            try PracticeEntryDraft(part: library.addPart(song: "Song \(index)", instrument: "Guitar"), rating: rating)
        }

        #expect(!library.canLogPracticeSession(duration: duration, drafts: drafts, isPracticeNextOn: true))
        let session = try library.logPracticeSession(
            startDate: TestClock.start,
            duration: duration,
            note: "",
            drafts: drafts,
            isPracticeNextOn: true,
        )
        #expect(session == nil)
        #expect(library.practiceSessions().isEmpty)
        #expect(drafts.allSatisfy { library.practiceEntries(of: $0.part.id).isEmpty })
    }

    @Test func `a Practice Session whose drafts' Parts were all deleted is not saved`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let draft = PracticeEntryDraft(part: part, rating: .good)
        try library.deletePart(id: part.id)

        let session = try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 30 * 60,
            note: "",
            drafts: [draft],
            isPracticeNextOn: true,
        )

        #expect(session == nil)
        #expect(library.practiceSessions().isEmpty)
    }

    @Test func `a Practice Session with a duration and every Practice Entry Draft rated is ready to save`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")

        let drafts = [PracticeEntryDraft(part: part, rating: .again)]

        #expect(library.canLogPracticeSession(duration: 60, drafts: drafts, isPracticeNextOn: true))
    }

    @Test func `logging a Practice Session saves the session and all its Practice Entries at once`() throws {
        let container = PersistentStore.container()
        let library = PracticeLibrary(container: container, now: { TestClock.start })
        let wonderwall = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let yesterday = try library.addPart(song: "Yesterday", instrument: "Piano")
        var saves = 0
        let observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: container.viewContext,
            queue: nil,
        ) { _ in
            MainActor.assumeIsolated {
                saves += 1
            }
        }
        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 30 * 60,
            note: "",
            drafts: [
                PracticeEntryDraft(part: wonderwall, rating: .good),
                PracticeEntryDraft(part: yesterday, rating: .hard),
            ],
            isPracticeNextOn: true,
        )

        #expect(saves == 1)
    }

    @Test func `a logged Part is scheduled from all its Practice Entries, as if they were logged one by one`() throws {
        let earlier = try #require(time(2026, 1, 1, hour: 18))
        let oneByOne = PracticeLibrary.inMemory()
        let oneByOnePart = try oneByOne.addPart(song: "Wonderwall", instrument: "Guitar")
        let first = try oneByOne.addPracticeSession(startDate: earlier, duration: 1800)
        try oneByOne.addPracticeEntry(to: first.id, part: oneByOnePart.id, rating: .good)
        let second = try oneByOne.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try oneByOne.addPracticeEntry(to: second.id, part: oneByOnePart.id, rating: .hard)
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        try library.logPracticeSession(
            startDate: earlier,
            duration: 1800,
            note: "",
            drafts: [PracticeEntryDraft(part: part, rating: .good)],
            isPracticeNextOn: true,
        )

        try library.logPracticeSession(
            startDate: TestClock.start,
            duration: 1800,
            note: "",
            drafts: [PracticeEntryDraft(part: part, rating: .hard)],
            isPracticeNextOn: true,
        )

        let expected = try #require(oneByOne.part(id: oneByOnePart.id)?.dueDate)
        #expect(library.part(id: part.id)?.dueDate == expected)
        #expect(expected != day(2026, 1, 6))
    }

    @Test func `a Practice Session started 1 hour 15 minutes ago starts at 10:45 when it is noon`() {
        let library = PracticeLibrary.inMemory()

        #expect(library.startDate(hoursAgo: 1, minutesAgo: 15) == time(2026, 1, 5, hour: 10, minute: 45))
    }
}

private func day(_ year: Int, _ month: Int, _ day: Int) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
}

private func time(_ year: Int, _ month: Int, _ day: Int, hour: Int, minute: Int = 0) -> Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))
}

private extension PracticeLibrary {
    func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try addSong(title: title, artist: "")
        let instrument = try instruments().first { $0.name == name } ?? addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id))
    }
}
