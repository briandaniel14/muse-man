import Foundation
import MuseManCore
import Testing

struct RecordingTests {
    let take = Data("first take".utf8)

    @Test func `a Recording added to a Part is listed on that Part with its audio`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addGuitarPart()
        let other = try #require(try library.addPart(to: part.song.id, instrument: part.instrument.id, label: "Solo"))

        try library.addRecording(audio: take, to: part.id)

        let recording = try #require(library.recordings(of: part.id).first)
        #expect(library.recordings(of: part.id).count == 1)
        #expect(recording.date == clock.now)
        #expect(library.audio(of: recording.id) == take)
        #expect(library.recordings(of: other.id).isEmpty)
    }

    @Test func `a Part's Recordings are listed newest first, imported ones by their own date`() throws {
        let clock = TestClock()
        let library = PracticeLibrary.inMemory(clock: clock)
        let part = try library.addGuitarPart()
        let voiceMemo = try #require(Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1)))

        try library.addRecording(audio: Data("tuesday".utf8), to: part.id)
        clock.advance(days: 2)
        try library.addRecording(audio: Data("thursday".utf8), to: part.id)
        try library.addRecording(audio: Data("voice memo".utf8), date: voiceMemo, to: part.id)

        let recordings = library.recordings(of: part.id)
        #expect(recordings.map(\.date) == [clock.now, TestClock.start, voiceMemo])
        #expect(recordings.compactMap { library.audio(of: $0.id) } == ["thursday", "tuesday", "voice memo"].map {
            Data($0.utf8)
        })
    }

    @Test func `a deleted Recording leaves its Part`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let bad = try #require(try library.addRecording(audio: Data("bad take".utf8), to: part.id))
        let good = try #require(try library.addRecording(audio: take, to: part.id))

        try library.deleteRecording(id: bad.id)

        #expect(library.recordings(of: part.id) == [good])
        #expect(library.audio(of: bad.id) == nil)
        #expect(library.part(id: part.id) != nil)
    }

    @Test func `deleting a Part deletes its Recordings`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let recording = try #require(try library.addRecording(audio: take, to: part.id))

        try library.deletePart(id: part.id)

        #expect(library.recording(identifier: recording.identifier) == nil)
        #expect(library.audio(of: recording.id) == nil)
    }

    @Test func `deleting a Song deletes its Parts' Recordings`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let recording = try #require(try library.addRecording(audio: take, to: part.id))

        try library.deleteSong(id: part.song.id)

        #expect(library.recording(identifier: recording.identifier) == nil)
        #expect(library.audio(of: recording.id) == nil)
    }

    @Test func `a Recording is found by its identifier, with its Part`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addGuitarPart()
        let recording = try #require(try library.addRecording(audio: take, to: part.id))

        let found = try #require(library.recording(identifier: recording.identifier))

        #expect(found == recording)
        #expect(found.part == part.id)
        #expect(library.recording(identifier: UUID()) == nil)
    }

    @Test func `added Recordings and their audio persist across launches`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let library = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))
        let part = try library.addGuitarPart()
        let longTake = Data(repeating: 7, count: 2_000_000)
        let recording = try #require(try library.addRecording(audio: longTake, to: part.id))

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        let reloaded = try #require(relaunched.recording(identifier: recording.identifier))
        #expect(reloaded.date == recording.date)
        #expect(relaunched.audio(of: reloaded.id) == longTake)
    }
}

private extension PracticeLibrary {
    func addGuitarPart() throws -> Part {
        let song = try addSong(title: "Wonderwall", artist: "Oasis")
        let guitar = try addInstrument(name: "Guitar")
        return try #require(try addPart(to: song.id, instrument: guitar.id))
    }
}
