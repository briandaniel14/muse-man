import Foundation
import MuseManCore
import Testing

struct PlaybackBarTests {
    @Test func `a Song without an Apple Music song shows no playback bar`() {
        #expect(shown(for: nil, subscriber: true, previewURL: preview) == nil)
        #expect(shown(for: nil, subscriber: false, previewURL: preview) == nil)
    }

    @Test func `an Apple Music subscriber gets the full song`() {
        #expect(shown(for: wonderwall, subscriber: true, previewURL: preview) == .fullSong)
    }

    @Test func `a Musician without an Apple Music subscription gets the preview`() {
        #expect(shown(for: wonderwall, subscriber: false, previewURL: preview) == .preview(preview))
    }

    @Test func `a Musician without an Apple Music subscription gets no playback bar when the song has no preview`() {
        #expect(shown(for: wonderwall, subscriber: false, previewURL: nil) == nil)
    }

    private let wonderwall = AppleMusicSong(
        id: "1517447333",
        url: URL(string: "https://music.apple.com/us/album/wonderwall/1517447039?i=1517447333")!,
    )

    private let preview = URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview/wonderwall.m4a")!

    private func shown(for song: AppleMusicSong?, subscriber: Bool, previewURL: URL?) -> PlaybackBarContent? {
        PlaybackBarContent.shown(appleMusicSong: song, canPlayCatalogContent: subscriber, previewURL: previewURL)
    }
}
