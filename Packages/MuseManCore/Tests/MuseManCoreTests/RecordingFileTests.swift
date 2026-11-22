import Foundation
import MuseManCore
import Testing
import UniformTypeIdentifiers

struct RecordingFileTests {
    private func audio(_ bytes: [UInt8]) -> Data {
        Data(bytes + Array(repeating: 0, count: 16))
    }

    @Test func `a recorded m4a is shared as MPEG-4 audio`() {
        let m4a = audio([0, 0, 0, 0x20] + Array("ftypM4A ".utf8))
        #expect(RecordingFile.contentType(of: m4a) == .mpeg4Audio)
    }

    @Test func `imported MP3, WAV, AIFF and FLAC keep their own format`() {
        #expect(RecordingFile.contentType(of: audio(Array("ID3".utf8))) == .mp3)
        #expect(RecordingFile.contentType(of: audio([0xFF, 0xFB])) == .mp3)
        #expect(RecordingFile.contentType(of: audio(Array("RIFF".utf8) + [0, 0, 0, 0] + Array("WAVE".utf8))) == .wav)
        #expect(RecordingFile.contentType(of: audio(Array("FORM".utf8) + [0, 0, 0, 0] + Array("AIFF".utf8))) == .aiff)
        #expect(RecordingFile.contentType(of: audio(Array("fLaC".utf8))) == UTType("org.xiph.flac"))
    }

    @Test func `unrecognised audio falls back to MPEG-4 audio`() {
        #expect(RecordingFile.contentType(of: Data("voice memo".utf8)) == .mpeg4Audio)
    }

    @Test func `the file name is the Part and date with the format's extension`() throws {
        let date = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 22, hour: 9)))
        let file = RecordingFile(audio: audio(Array("ID3".utf8)), partName: "Wonderwall Guitar · Lead", date: date)

        #expect(file.fileName == "Wonderwall Guitar · Lead 2026-11-22.mp3")
    }

    @Test func `a recorded m4a is named with the m4a extension`() throws {
        let date = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 22, hour: 9)))
        let file = RecordingFile(audio: Data("voice memo".utf8), partName: "Wonderwall Guitar", date: date)

        #expect(file.fileName == "Wonderwall Guitar 2026-11-22.m4a")
    }

    @Test func `a named Recording's file is called by its name`() throws {
        let date = try #require(Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 22, hour: 9)))
        let audio = Data("voice memo".utf8)
        let file = RecordingFile(audio: audio, name: "Solo take 2", partName: "Wonderwall", date: date)

        #expect(file.fileName == "Solo take 2.m4a")
    }
}
