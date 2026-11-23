import MuseManCore
import Testing

struct InstrumentTests {
    @Test func `created Instruments are offered by name`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addInstrument(name: "Piano")
        try library.addInstrument(name: "bass")
        try library.addInstrument(name: "Guitar")

        #expect(library.instruments().map(\.name) == ["bass", "Guitar", "Piano"])
    }

    @Test func `renaming an Instrument renames it on its Parts`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        var guitar = try library.addInstrument(name: "Guitar")
        try library.addPart(to: song.id, instrument: guitar.id)

        guitar.name = "Acoustic Guitar"
        try library.updateInstrument(guitar)

        #expect(library.instruments().map(\.name) == ["Acoustic Guitar"])
        #expect(library.parts(of: song.id).map(\.instrument.name) == ["Acoustic Guitar"])
    }

    @Test func `an Instrument no Part uses can be deleted`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addInstrument(name: "Guitar")
        try library.addInstrument(name: "Piano")

        try library.deleteInstrument(id: guitar.id)

        #expect(library.instruments().map(\.name) == ["Piano"])
    }

    @Test func `deleting an Instrument that Parts use is refused, saying how many`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let blackbird = try library.addSong(title: "Blackbird", artist: "The Beatles")
        let guitar = try library.addInstrument(name: "Guitar")
        try library.addPart(to: wonderwall.id, instrument: guitar.id)
        try library.addPart(to: blackbird.id, instrument: guitar.id)

        #expect(throws: InstrumentInUseError(partCount: 2)) {
            try library.deleteInstrument(id: guitar.id)
        }
        #expect(library.instruments().map(\.name) == ["Guitar"])
        #expect(library.parts(instrument: guitar.id).count == 2)
    }
}
