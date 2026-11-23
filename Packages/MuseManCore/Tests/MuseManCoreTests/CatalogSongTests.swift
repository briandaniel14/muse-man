import MuseManCore
import Testing

struct CatalogSongTests {
    @Test func `versions of the same Song by the same artist are looked up after the chosen one`() {
        let chosen = song("Wonderwall (Remastered)", by: "Oasis", isrc: "REMASTER")
        let results = [
            song("Wonderwall", by: "Oasis", isrc: "STUDIO"),
            song("Wonderwall", by: "Ryan Adams", isrc: "COVER"),
            chosen,
            song("Wonderwall - Live at Wembley", by: "oasis", isrc: "LIVE"),
            song("Wonderwall [Demo]", by: "Oasis", isrc: nil),
            song("Wonderwall (Remastered)", by: "Oasis", isrc: "REMASTER"),
            song("Champagne Supernova", by: "Oasis", isrc: "OTHER"),
        ]

        #expect(chosen.versionISRCs(in: results) == ["REMASTER", "STUDIO", "LIVE"])
    }

    @Test func `a Song with no other versions is looked up on its own`() {
        let chosen = song("Creep", by: "Radiohead", isrc: "CREEP")

        #expect(chosen.versionISRCs(in: [chosen]) == ["CREEP"])
    }

    private func song(_ title: String, by artist: String, isrc: String?) -> CatalogSong {
        CatalogSong(id: title + artist, title: title, artist: artist, album: nil, artwork: nil, isrc: isrc)
    }
}
