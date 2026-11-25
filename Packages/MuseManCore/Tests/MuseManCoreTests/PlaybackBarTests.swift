import Foundation
import MuseManCore
import Testing

struct PlaybackBarTests {
    @Test func `a Song without an Apple Music song shows no playback bar`() {
        #expect(PlaybackBarContent.shown(appleMusicSong: nil, canPlayCatalogContent: true) == nil)
        #expect(PlaybackBarContent.shown(appleMusicSong: nil, canPlayCatalogContent: false) == nil)
    }

    @Test func `an Apple Music subscriber gets the full song`() {
        #expect(PlaybackBarContent.shown(appleMusicSong: wonderwall, canPlayCatalogContent: true) == .fullSong)
    }

    @Test func `a Musician without an Apple Music subscription gets no playback bar`() {
        #expect(PlaybackBarContent.shown(appleMusicSong: wonderwall, canPlayCatalogContent: false) == nil)
    }

    private let wonderwall = AppleMusicSong(
        id: "1517447333",
        url: URL(string: "https://music.apple.com/us/album/wonderwall/1517447039?i=1517447333")!,
    )
}
