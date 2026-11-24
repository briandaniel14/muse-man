import Foundation
import MuseManCore
import Testing

struct CoverGridTests {
    private let library = PracticeLibrary.inMemory()

    private func cover(_ name: String) -> URL? {
        URL(string: "https://example.com/\(name).jpg")
    }

    private func songs(_ titles: [String]) throws -> [Song] {
        try titles.map { try library.addSong(title: $0, artist: "Artist", artworkURL: cover($0)) }
    }

    @Test func `four Songs fill the grid in reading order`() throws {
        let songs = try songs(["A", "B", "C", "D"])

        let layout = CoverGridLayout(songs: songs)

        #expect(layout.columns == [[cover("A"), cover("C")], [cover("B"), cover("D")]])
    }

    @Test func `no Songs leave the grid empty for the placeholder`() {
        #expect(CoverGridLayout(songs: []).columns.isEmpty)
    }

    @Test func `one Song fills the whole square`() throws {
        let songs = try songs(["A"])

        #expect(CoverGridLayout(songs: songs).columns == [[cover("A")]])
    }

    @Test func `two Songs split the square side by side`() throws {
        let songs = try songs(["A", "B"])

        #expect(CoverGridLayout(songs: songs).columns == [[cover("A")], [cover("B")]])
    }

    @Test func `three Songs put the first on the left and stack the others on the right`() throws {
        let songs = try songs(["A", "B", "C"])

        #expect(CoverGridLayout(songs: songs).columns == [[cover("A")], [cover("B"), cover("C")]])
    }

    @Test func `only the first four Songs are shown`() throws {
        let songs = try songs(["A", "B", "C", "D", "E"])

        #expect(CoverGridLayout(songs: songs).columns == [[cover("A"), cover("C")], [cover("B"), cover("D")]])
    }

    @Test func `reordering a Collection reorders its grid`() throws {
        let gig = try library.addCollection(name: "Friday Gig")
        for song in try songs(["A", "B", "C", "D", "E"]) {
            try library.addSong(song.id, to: gig.id)
        }

        try library.moveSongs(in: gig.id, fromOffsets: [4], toOffset: 0)

        let layout = CoverGridLayout(songs: library.songs(in: gig.id))
        #expect(layout.columns == [[cover("E"), cover("B")], [cover("A"), cover("C")]])
    }

    @Test func `a Song without a cover keeps its tile for the placeholder`() throws {
        let songs = try [library.addSong(title: "A", artist: "Artist")] + songs(["B"])

        #expect(CoverGridLayout(songs: songs).columns == [[nil], [cover("B")]])
    }
}
