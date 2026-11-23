import Foundation
import MuseManCore
import Testing

struct SongTests {
    @Test func `added Song appears in the Library`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addSong(title: "Wonderwall", artist: "Oasis")

        let songs = library.songs()
        #expect(songs.map(\.title) == ["Wonderwall"])
        #expect(songs.map(\.artist) == ["Oasis"])
        #expect(songs.first?.key == nil)
        #expect(songs.first?.tempo == nil)
    }

    @Test func `a Song keeps an optional key and tempo`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addSong(title: "Blackbird", artist: "The Beatles", key: "G", tempo: 94)

        let song = try #require(library.songs().first)
        #expect(song.key == "G")
        #expect(song.tempo == 94)
    }

    @Test func `a Song keeps its artwork`() throws {
        let library = PracticeLibrary.inMemory()
        let artwork = try #require(URL(string: "https://example.com/cover.jpg"))
        let replacement = try #require(URL(string: "https://example.com/other.jpg"))

        var song = try library.addSong(title: "Creep", artist: "Radiohead", artworkURL: artwork)
        #expect(library.song(id: song.id)?.artworkURL == artwork)

        song.artworkURL = replacement
        try library.updateSong(song)
        #expect(library.song(id: song.id)?.artworkURL == replacement)
    }

    @Test func `every Song is listed by title`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addSong(title: "Wonderwall", artist: "Oasis")
        try library.addSong(title: "blackbird", artist: "The Beatles")
        try library.addSong(title: "Hallelujah", artist: "Leonard Cohen")

        #expect(library.songs().map(\.title) == ["blackbird", "Hallelujah", "Wonderwall"])
    }

    @Test func `search finds Songs by title or artist, ignoring case`() throws {
        let library = PracticeLibrary.inMemory()
        try library.addSong(title: "Wonderwall", artist: "Oasis")
        try library.addSong(title: "Blackbird", artist: "The Beatles")
        try library.addSong(title: "Help!", artist: "The Beatles")

        #expect(library.songs(matching: "WONDER").map(\.title) == ["Wonderwall"])
        #expect(library.songs(matching: "beatles").map(\.title) == ["Blackbird", "Help!"])
        #expect(library.songs(matching: "Radiohead").isEmpty)
    }

    @Test func `blank search lists every Song`() throws {
        let library = PracticeLibrary.inMemory()
        try library.addSong(title: "Wonderwall", artist: "Oasis")
        try library.addSong(title: "Blackbird", artist: "The Beatles")

        #expect(library.songs(matching: "  ").map(\.title) == ["Blackbird", "Wonderwall"])
    }

    @Test func `editing a Song changes its title, artist, key and tempo`() throws {
        let library = PracticeLibrary.inMemory()
        var song = try library.addSong(title: "Wonderwal", artist: "Oasys", key: "F#m", tempo: 86)

        song.title = "Wonderwall"
        song.artist = "Oasis"
        song.key = nil
        song.tempo = 87
        try library.updateSong(song)

        let edited = try #require(library.song(id: song.id))
        #expect(edited.title == "Wonderwall")
        #expect(edited.artist == "Oasis")
        #expect(edited.key == nil)
        #expect(edited.tempo == 87)
        #expect(library.songs().count == 1)
    }

    @Test func `deleted Song leaves the Library`() throws {
        let library = PracticeLibrary.inMemory()
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        try library.addSong(title: "Blackbird", artist: "The Beatles")

        try library.deleteSong(id: wonderwall.id)

        #expect(library.songs().map(\.title) == ["Blackbird"])
        #expect(library.song(id: wonderwall.id) == nil)
    }

    @Test func `reading Songs is observed, so screens refresh when they change`() throws {
        let library = PracticeLibrary.inMemory()
        nonisolated(unsafe) var changed = false
        withObservationTracking {
            _ = library.songs()
        } onChange: {
            changed = true
        }

        try library.addSong(title: "Wonderwall", artist: "Oasis")

        #expect(changed)
    }

    @Test func `added Songs persist across launches`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        try PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))
            .addSong(title: "Wonderwall", artist: "Oasis", key: "F#m", tempo: 87)

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        let song = try #require(relaunched.songs().first)
        #expect(song.title == "Wonderwall")
        #expect(song.key == "F#m")
        #expect(song.tempo == 87)
    }
}
