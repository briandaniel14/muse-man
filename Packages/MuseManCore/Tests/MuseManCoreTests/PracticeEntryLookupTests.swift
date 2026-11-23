import CoreData
import Foundation
import MuseManCore
import Testing

struct PracticeEntryLookupTests {
    @Test func `each Practice Entry comes with its Part and Recording`() throws {
        let library = PracticeLibrary.inMemory()
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let recording = try #require(try library.addRecording(audio: Data("take one".utf8), to: guitar.id))
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .good, recordingID: recording.identifier)
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .hard)

        let entries = library.practiceEntries(in: session.id)

        #expect(entries.map(\.part?.instrument.name) == ["Guitar", "Piano"])
        #expect(entries.map(\.recording?.id) == [recording.id, nil])
        #expect(library.practiceEntries(of: guitar.id).first?.recording?.id == recording.id)
        #expect(library.practiceEntries(of: guitar.id).first?.part?.id == guitar.id)
    }

    @Test func `a Practice Entry whose Part is gone still shows, without the Part`() throws {
        let container = PersistentStore.container()
        let library = PracticeLibrary(container: container)
        let guitar = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let piano = try library.addPart(song: "Yesterday", instrument: "Piano")
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: session.id, part: guitar.id, rating: .hard, note: "chorus")
        try library.addPracticeEntry(to: session.id, part: piano.id, rating: .easy)

        try container.viewContext.delete(container.viewContext.existingObject(with: guitar.id))
        try container.viewContext.save()

        let entries = library.practiceEntries(in: session.id)
        #expect(entries.map(\.note) == ["chorus", ""])
        #expect(entries.map(\.part?.id) == [nil, piano.id])
    }

    @Test func `editing a Practice Entry whose Recording is gone keeps its reference to the Recording`() throws {
        let library = PracticeLibrary.inMemory()
        let part = try library.addPart(song: "Wonderwall", instrument: "Guitar")
        let recording = try #require(try library.addRecording(audio: Data("take one".utf8), to: part.id))
        let session = try library.addPracticeSession(startDate: TestClock.start, duration: 1800)
        try library.addPracticeEntry(to: session.id, part: part.id, rating: .good, recordingID: recording.identifier)
        try library.deleteRecording(id: recording.id)

        var entry = try #require(library.practiceEntries(in: session.id).first)
        #expect(entry.recording == nil)
        entry.note = "edited"
        try library.updatePracticeEntry(entry)

        #expect(library.practiceEntries(in: session.id).first?.recordingID == recording.identifier)
    }
}

private extension PracticeLibrary {
    @discardableResult func addPart(song title: String, instrument name: String) throws -> Part {
        let song = try addSong(title: title, artist: "")
        let instrument = try addInstrument(name: name)
        return try #require(try addPart(to: song.id, instrument: instrument.id))
    }
}
