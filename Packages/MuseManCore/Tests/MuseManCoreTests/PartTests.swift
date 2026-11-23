import Foundation
import MuseManCore
import Testing

struct PartTests {
    @Test func `added Part shows on its Song, wanting to be learned`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try library.addInstrument(name: "Guitar")

        try library.addPart(to: song.id, instrument: guitar.id, label: "Lead")

        let part = try #require(library.parts(of: song.id).first)
        #expect(library.parts(of: song.id).count == 1)
        #expect(part.song.title == "Wonderwall")
        #expect(part.instrument.name == "Guitar")
        #expect(part.label == "Lead")
        #expect(part.status == .wantToLearn)
        #expect(part.note == "")
        #expect(part.dueDate == nil)
        #expect(part.owner == "")
    }

    @Test func `a Song has several Parts, two on the same Instrument, listed by Instrument then label`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let otherSong = try library.addSong(title: "Blackbird", artist: "The Beatles")
        let piano = try library.addInstrument(name: "Piano")
        let guitar = try library.addInstrument(name: "Guitar")

        try library.addPart(to: song.id, instrument: piano.id)
        try library.addPart(to: song.id, instrument: guitar.id, label: "Rhythm")
        try library.addPart(to: song.id, instrument: guitar.id, label: "Lead")
        try library.addPart(to: otherSong.id, instrument: guitar.id)

        let parts = library.parts(of: song.id)
        #expect(parts.map(\.instrument.name) == ["Guitar", "Guitar", "Piano"])
        #expect(parts.map(\.label) == ["Lead", "Rhythm", nil])
        #expect(Set(parts.map(\.identifier)).count == 3)
        #expect(library.parts(of: otherSong.id).count == 1)
    }

    @Test func `an Instrument created for one Song is offered for the next`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let blackbird = try library.addSong(title: "Blackbird", artist: "The Beatles")
        try library.addPart(to: wonderwall.id, instrument: library.addInstrument(name: "Guitar").id)

        let offered = try #require(library.instruments().first)
        try library.addPart(to: blackbird.id, instrument: offered.id)

        #expect(library.instruments().map(\.name) == ["Guitar"])
        #expect(library.parts(of: blackbird.id).map(\.instrument) == [offered])
    }

    @Test func `a Part's Status moves in any direction and its Part Note is kept`() throws {
        let library = PracticeLibrary.inMemory()
        var part = try library.addGuitarPart()

        for status in [Part.Status.learned, .wantToLearn, .learning, .learned, .learning, .wantToLearn] {
            part.status = status
            try library.updatePart(part)
            #expect(library.part(id: part.id)?.status == status)
        }

        part.note = "Capo 2, Em7 shape"
        try library.updatePart(part)
        part.note = "Capo 2, Em7 shape\nWatch the bridge"
        try library.updatePart(part)

        #expect(library.part(id: part.id)?.note == "Capo 2, Em7 shape\nWatch the bridge")
    }

    @Test func `moving to Learning without a due date makes it due today`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        var part = try library.addGuitarPart()
        clock.advance(days: 2)

        part.status = .learning
        try library.updatePart(part)

        #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 7))
    }

    @Test func `a due date is kept whenever the Status changes`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        var part = try library.addGuitarPart()
        part.status = .learning
        try library.updatePart(part)

        for status in [Part.Status.learned, .wantToLearn, .learning, .wantToLearn, .learned, .learning] {
            clock.advance(days: 3)
            part.status = status
            try library.updatePart(part)
            #expect(library.part(id: part.id)?.dueDate == day(2026, 1, 5))
        }
    }

    @Test func `a deleted Part leaves its Song`() throws {
        let library = PracticeLibrary.inMemory()
        let lead = try library.addGuitarPart()
        let rhythm = try #require(
            try library.addPart(to: lead.song.id, instrument: lead.instrument.id, label: "Rhythm"),
        )

        try library.deletePart(id: lead.id)

        #expect(library.part(id: lead.id) == nil)
        #expect(library.parts(of: lead.song.id) == [rhythm])
        #expect(library.instruments() == [lead.instrument])
    }

    @Test func `deleting a Song deletes its Parts but keeps their Instruments`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()

        try library.deleteSong(id: part.song.id)

        #expect(library.part(id: part.id) == nil)
        #expect(library.instruments().map(\.name) == ["Guitar"])
    }

    @Test func `added Parts persist across launches`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let clock = TestClock()
        let library = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL), now: { clock.now })
        var part = try library.addGuitarPart()
        part.status = .learning
        part.note = "Capo 2"
        try library.updatePart(part)

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        let reloaded = try #require(relaunched.songs().first.flatMap { relaunched.parts(of: $0.id).first })
        #expect(reloaded.identifier == part.identifier)
        #expect(reloaded.instrument.name == "Guitar")
        #expect(reloaded.status == .learning)
        #expect(reloaded.note == "Capo 2")
        #expect(reloaded.dueDate == day(2026, 1, 5))
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        let song = try addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try addInstrument(name: "Guitar")
        return try #require(try addPart(to: song.id, instrument: guitar.id))
    }
}
