import CoreData
import Foundation
import MuseManCore
import Testing

struct ResourceTests {
    let tab = URL(string: "https://tabs.ultimate-guitar.com/tab/oasis/wonderwall-chords-27596")!

    @Test func `a Resource added to a Song is listed on that Song`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let other = try library.addSong(title: "Blackbird", artist: "The Beatles")

        try library.addResource(url: tab, title: "UG tab", to: song.id)

        let resources = library.resources(for: song.id)
        #expect(resources.map(\.url) == [tab])
        #expect(resources.map(\.title) == ["UG tab"])
        #expect(library.resources(for: other.id).isEmpty)
    }

    @Test func `a Resource's title is optional, and a blank title counts as none`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")

        try library.addResource(url: tab, to: song.id)
        try library.addResource(url: tab, title: "   ", to: song.id)

        #expect(library.resources(for: song.id).map(\.title) == [nil, nil])
    }

    @Test func `a Song's Resources are listed by title, or by site when untitled`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let lesson = try #require(URL(string: "https://www.youtube.com/watch?v=bx1Bh8ZvH84"))
        let chords = try #require(URL(string: "https://chordify.net/chords/oasis-wonderwall"))

        try library.addResource(url: lesson, title: "Marty Music lesson", to: song.id)
        try library.addResource(url: tab, title: "UG tab", to: song.id)
        try library.addResource(url: chords, to: song.id)

        #expect(library.resources(for: song.id).map(\.url) == [chords, lesson, tab])
    }

    @Test func `editing a Resource changes its link and title`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        var resource = try #require(try library.addResource(url: tab, title: "UG tab", to: song.id))
        let lesson = try #require(URL(string: "https://www.youtube.com/watch?v=bx1Bh8ZvH84"))

        resource.url = lesson
        resource.title = nil
        try library.updateResource(resource)

        let resources = library.resources(for: song.id)
        #expect(resources.map(\.url) == [lesson])
        #expect(resources.map(\.title) == [nil])
    }

    @Test func `a deleted Resource leaves its Song`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let dead = try #require(try library.addResource(url: tab, title: "Dead link", to: song.id))
        try library.addResource(url: tab, title: "UG tab", to: song.id)

        try library.deleteResource(id: dead.id)

        #expect(library.resources(for: song.id).map(\.title) == ["UG tab"])
    }

    @Test func `deleting a Song deletes its Resources`() throws {
        let container = PersistentStore.container()
        let library = PracticeLibrary(container: container)
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let resource = try #require(try library.addResource(url: tab, to: song.id))
        #expect(library.resources(for: song.id) == [resource])

        try library.deleteSong(id: song.id)

        let resources = NSFetchRequest<NSFetchRequestResult>(entityName: "Resource")
        #expect(try container.viewContext.count(for: resources) == 0)
    }

    @Test func `reading Resources is observed, so screens refresh when they change`() throws {
        let library = PracticeLibrary.inMemory()
        let song = try library.addSong(title: "Wonderwall", artist: "Oasis")
        nonisolated(unsafe) var changed = false
        withObservationTracking {
            _ = library.resources(for: song.id)
        } onChange: {
            changed = true
        }

        try library.addResource(url: tab, to: song.id)

        #expect(changed)
    }
}
