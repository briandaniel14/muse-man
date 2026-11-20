import MuseManCore
import Testing

struct PartsFilterTests {
    @Test func `every Part is listed with its Song and Instrument, by Song then Instrument`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let blackbird = try library.addSong(title: "Blackbird", artist: "The Beatles")
        let piano = try library.addInstrument(name: "Piano")
        let guitar = try library.addInstrument(name: "Guitar")
        try library.addPart(to: wonderwall.id, instrument: piano.id)
        try library.addPart(to: wonderwall.id, instrument: guitar.id, label: "Lead")
        try library.addPart(to: blackbird.id, instrument: guitar.id)

        let parts = library.parts()

        #expect(parts.map(\.song.title) == ["Blackbird", "Wonderwall", "Wonderwall"])
        #expect(parts.map(\.instrument.name) == ["Guitar", "Guitar", "Piano"])
        #expect(parts.map(\.label) == [nil, "Lead", nil])
    }

    @Test func `filtering by Status shows only Parts with that Status`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addInstrument(name: "Guitar")
        let wonderwall = try library.addPart(of: "Wonderwall", on: guitar)
        let blackbird = try library.addPart(of: "Blackbird", on: guitar)
        try library.addPart(of: "Yesterday", on: guitar)
        try library.set(wonderwall, to: .learning)
        try library.set(blackbird, to: .learned)

        #expect(library.parts(status: .wantToLearn).map(\.song.title) == ["Yesterday"])
        #expect(library.parts(status: .learning).map(\.song.title) == ["Wonderwall"])
        #expect(library.parts(status: .learned).map(\.song.title) == ["Blackbird"])
    }

    @Test func `filtering by Instrument shows only Parts on that Instrument`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addInstrument(name: "Guitar")
        let piano = try library.addInstrument(name: "Piano")
        try library.addPart(of: "Wonderwall", on: guitar)
        try library.addPart(of: "Wonderwall", on: piano)
        try library.addPart(of: "Clair de Lune", on: piano)

        #expect(library.parts(instrument: piano.id).map(\.song.title) == ["Clair de Lune", "Wonderwall"])
        #expect(library.parts(instrument: guitar.id).map(\.song.title) == ["Wonderwall"])
    }

    @Test func `filtering by Status and Instrument together shows Parts matching both`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addInstrument(name: "Guitar")
        let piano = try library.addInstrument(name: "Piano")
        try library.set(library.addPart(of: "Wonderwall", on: guitar), to: .learning)
        try library.set(library.addPart(of: "Wonderwall", on: piano), to: .learning)
        try library.addPart(of: "Clair de Lune", on: piano)

        let parts = library.parts(status: .learning, instrument: piano.id)

        #expect(parts.map(\.song.title) == ["Wonderwall"])
        #expect(parts.map(\.instrument.name) == ["Piano"])
    }
}

private extension PracticeLibrary {
    @discardableResult func addPart(of title: String, on instrument: Instrument, label: String? = nil) throws -> Part {
        let song = try songs(matching: title).first ?? addSong(title: title, artist: "")
        return try #require(try addPart(to: song.id, instrument: instrument.id, label: label))
    }

    func set(_ part: Part, to status: Part.Status) throws {
        var part = part
        part.status = status
        try updatePart(part)
    }
}
