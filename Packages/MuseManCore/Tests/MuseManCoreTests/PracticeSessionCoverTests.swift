import CoreData
import Foundation
import MuseManCore
import Testing

struct PracticeSessionCoverTests {
    private let clock = TestClock()
    private let container = PersistentStore.container()
    private let library: PracticeLibrary

    init() {
        library = PracticeLibrary(container: container, now: { [clock] in clock.now })
    }

    @Test func `the most recently practised Songs come first`() throws {
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)
        for title in ["A", "B", "C", "D", "E"] {
            try practise(addPart(song: title, instrument: "Guitar"), in: session)
        }

        let titles = library.practisedSongs(in: session.id).map(\.title)

        #expect(titles == ["E", "D", "C", "B", "A"])
    }

    @Test func `a Song practised on two Parts appears once`() throws {
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try library.addInstrument(name: "Guitar")
        let piano = try library.addInstrument(name: "Piano")
        let guitarPart = try #require(try library.addPart(to: wonderwall.id, instrument: guitar.id))
        let pianoPart = try #require(try library.addPart(to: wonderwall.id, instrument: piano.id))
        try practise(guitarPart, in: session)
        try practise(addPart(song: "Yesterday", instrument: "Bass"), in: session)
        try practise(pianoPart, in: session)

        let titles = library.practisedSongs(in: session.id).map(\.title)

        #expect(titles == ["Wonderwall", "Yesterday"])
    }

    @Test func `a Practice Entry whose Part is gone is skipped`() throws {
        let session = try library.addPracticeSession(startDate: clock.now, duration: 30 * 60)
        try practise(addPart(song: "Wonderwall", instrument: "Guitar"), in: session)
        let yesterday = try addPart(song: "Yesterday", instrument: "Piano")
        try practise(yesterday, in: session)

        try container.viewContext.delete(container.viewContext.existingObject(with: yesterday.id))
        try container.viewContext.save()

        #expect(library.practisedSongs(in: session.id).map(\.title) == ["Wonderwall"])
    }

    private func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try library.addSong(title: title, artist: "Artist")
        let instrument = try library.addInstrument(name: name)
        return try #require(try library.addPart(to: song.id, instrument: instrument.id))
    }

    private func practise(_ part: Part, in session: PracticeSession) throws {
        clock.now += 60
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good)
    }
}
