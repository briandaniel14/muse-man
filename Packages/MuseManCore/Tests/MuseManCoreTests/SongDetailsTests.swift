import Foundation
import MuseManCore
import Testing

struct SongDetailsTests {
    @Test func `audio features give a major key and rounded tempo`() throws {
        let data = features(track("A", key: 8, mode: 1, tempo: 95.009))

        let details = try #require(SongDetails(audioFeatures: data, preferring: ["A"]))

        #expect(details == SongDetails(key: "A♭ major", tempo: 95))
    }

    @Test func `minor keys are spelled with sharps where musicians expect them`() throws {
        let data = features(track("A", key: 1, mode: 0, tempo: 137.6))

        let details = try #require(SongDetails(audioFeatures: data, preferring: ["A"]))

        #expect(details == SongDetails(key: "C♯ minor", tempo: 138))
    }

    @Test func `an unknown key leaves the key blank`() throws {
        let data = features(track("A", key: -1, mode: 1, tempo: 120))

        let details = try #require(SongDetails(audioFeatures: data, preferring: ["A"]))

        #expect(details == SongDetails(key: nil, tempo: 120))
    }

    @Test func `the chosen recording wins over other versions`() throws {
        let data = features(track("LIVE", key: 2, mode: 1, tempo: 90), track("STUDIO", key: 6, mode: 0, tempo: 87))

        let details = try #require(SongDetails(audioFeatures: data, preferring: ["STUDIO", "LIVE"]))

        #expect(details == SongDetails(key: "F♯ minor", tempo: 87))
    }

    @Test func `another version fills in when the chosen recording has no features`() throws {
        let data = features(track("LIVE", key: 2, mode: 1, tempo: 90))

        let details = try #require(SongDetails(audioFeatures: data, preferring: ["REMASTER", "LIVE"]))

        #expect(details == SongDetails(key: "D major", tempo: 90))
    }

    @Test func `no matching recording gives no details`() {
        let data = features(track("OTHER", key: 2, mode: 1, tempo: 90))

        #expect(SongDetails(audioFeatures: data, preferring: ["A"]) == nil)
        #expect(SongDetails(audioFeatures: Data(#"{"content":[]}"#.utf8), preferring: ["A"]) == nil)
    }

    private func features(_ tracks: String...) -> Data {
        Data(#"{"content":[\#(tracks.joined(separator: ","))]}"#.utf8)
    }

    private func track(_ isrc: String, key: Int, mode: Int, tempo: Double) -> String {
        #"{"isrc":"\#(isrc)","key":\#(key),"mode":\#(mode),"tempo":\#(tempo)}"#
    }
}
