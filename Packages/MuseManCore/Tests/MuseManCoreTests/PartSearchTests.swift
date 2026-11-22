import MuseManCore
import Testing

struct PartSearchTests {
    private func library() throws -> PracticeLibrary {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let blackbird = try library.addSong(title: "Blackbird", artist: "The Beatles")
        let piano = try library.addInstrument(name: "Piano")
        let guitar = try library.addInstrument(name: "Guitar")
        try library.addPart(to: wonderwall.id, instrument: piano.id)
        try library.addPart(to: wonderwall.id, instrument: guitar.id, label: "Lead")
        try library.addPart(to: blackbird.id, instrument: guitar.id)
        return library
    }

    @Test func `a Part is found by its Song title, artist, Instrument or label, ignoring case`() throws {
        let library = try library()

        #expect(library.parts(matching: "wonder").map(\.instrument.name) == ["Guitar", "Piano"])
        #expect(library.parts(matching: "BEATLES").map(\.song.title) == ["Blackbird"])
        #expect(library.parts(matching: "piano").map(\.song.title) == ["Wonderwall"])
        #expect(library.parts(matching: "lead").map(\.label) == ["Lead"])
    }

    @Test func `every word must match somewhere in the Part`() throws {
        let library = try library()

        #expect(library.parts(matching: "wonderwall guitar").map(\.label) == ["Lead"])
        #expect(library.parts(matching: "blackbird piano").isEmpty)
    }

    @Test func `blank search lists every Part`() throws {
        let library = try library()

        #expect(library.parts(matching: " ").count == 3)
    }
}
