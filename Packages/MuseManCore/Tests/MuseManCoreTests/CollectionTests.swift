import CoreData
import Foundation
import MuseManCore
import Testing

struct CollectionTests {
    @Test func `created Collections are listed by name`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addCollection(name: "Friday Gig")
        try library.addCollection(name: "acoustic Set")

        #expect(library.collections().map(\.name) == ["acoustic Set", "Friday Gig"])
    }

    @Test func `a renamed Collection keeps its name`() throws {
        let library = PracticeLibrary.inMemory()
        var collection = try library.addCollection(name: "Friday Gig")

        collection.name = "Saturday Gig"
        try library.updateCollection(collection)

        #expect(library.collections().map(\.name) == ["Saturday Gig"])
    }

    @Test func `a Collection Note can be written, edited and cleared`() throws {
        let library = PracticeLibrary.inMemory()
        var collection = try library.addCollection(name: "Friday Gig")
        #expect(library.collections().first?.note == "")

        collection.note = "Bring the capo"
        try library.updateCollection(collection)
        #expect(library.collections().first?.note == "Bring the capo")

        collection.note = "Bring the capo\nSpare strings"
        try library.updateCollection(collection)
        #expect(library.collections().first?.note == "Bring the capo\nSpare strings")

        collection.note = ""
        try library.updateCollection(collection)
        #expect(library.collections().first?.note == "")
    }

    @Test func `a Collection lists its Songs in the order they were added`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let blackbird = try library.addSong(title: "Blackbird", artist: "The Beatles")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")

        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)
        try library.addSong(blackbird.id, to: gig.id)

        #expect(library.songs(in: gig.id).map(\.title) == ["Wonderwall", "Creep", "Blackbird"])
    }

    @Test func `a Song can be in several Collections`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let acoustic = try library.addCollection(name: "Acoustic Set")
        let empty = try library.addCollection(name: "Empty")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")

        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)
        try library.addSong(wonderwall.id, to: acoustic.id)

        #expect(library.songs(in: gig.id).map(\.title) == ["Wonderwall", "Creep"])
        #expect(library.songs(in: acoustic.id).map(\.title) == ["Wonderwall"])
        #expect(library.songs(in: empty.id).isEmpty)
    }

    @Test func `adding a Song already in a Collection leaves it where it was`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")
        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)

        try library.addSong(wonderwall.id, to: gig.id)

        #expect(library.songs(in: gig.id).map(\.title) == ["Wonderwall", "Creep"])
    }

    @Test func `reordered Songs keep their new order across launches`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let library = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))
        let gig = try library.addCollection(name: "Friday Gig")
        for title in ["Wonderwall", "Creep", "Blackbird", "Yellow"] {
            try library.addSong(library.addSong(title: title, artist: "").id, to: gig.id)
        }

        try library.moveSongs(in: gig.id, fromOffsets: [3], toOffset: 0)
        try library.moveSongs(in: gig.id, fromOffsets: [1], toOffset: 4)

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))
        let collection = try #require(relaunched.collections().first)
        #expect(relaunched.songs(in: collection.id).map(\.title) == ["Yellow", "Creep", "Blackbird", "Wonderwall"])
    }

    @Test func `a Song removed from a Collection stays in the Library and its other Collections`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let acoustic = try library.addCollection(name: "Acoustic Set")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")
        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)
        try library.addSong(wonderwall.id, to: acoustic.id)

        try library.removeSong(wonderwall.id, from: gig.id)

        #expect(library.songs(in: gig.id).map(\.title) == ["Creep"])
        #expect(library.songs(in: acoustic.id).map(\.title) == ["Wonderwall"])
        #expect(library.song(id: wonderwall.id) == wonderwall)
    }

    @Test func `each Song in a Collection shows its Parts and their Status`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")
        let guitar = try library.addInstrument(name: "Guitar")
        var lead = try #require(try library.addPart(to: wonderwall.id, instrument: guitar.id, label: "Lead"))
        lead.status = .learning
        try library.updatePart(lead)
        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)

        let readiness = library.songs(in: gig.id).map { song in
            library.parts(of: song.id).map { "\($0.instrument.name) \($0.label ?? ""): \($0.status.title)" }
        }

        #expect(readiness == [["Guitar Lead: Learning"], []])
    }

    @Test func `a deleted Song disappears from every Collection`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        let acoustic = try library.addCollection(name: "Acoustic Set")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        let creep = try library.addSong(title: "Creep", artist: "Radiohead")
        try library.addSong(wonderwall.id, to: gig.id)
        try library.addSong(creep.id, to: gig.id)
        try library.addSong(wonderwall.id, to: acoustic.id)

        try library.deleteSong(id: wonderwall.id)

        #expect(library.songs(in: gig.id).map(\.title) == ["Creep"])
        #expect(library.songs(in: acoustic.id).isEmpty)
        #expect(library.collections().count == 2)
    }

    @Test func `a deleted Collection is gone, but its Songs stay in the Library`() throws {
        let library = PracticeLibrary.inMemory()
        let gig = try library.addCollection(name: "Friday Gig")
        try library.addCollection(name: "Acoustic Set")
        let wonderwall = try library.addSong(title: "Wonderwall", artist: "Oasis")
        try library.addSong(wonderwall.id, to: gig.id)

        try library.deleteCollection(id: gig.id)

        #expect(library.collections().map(\.name) == ["Acoustic Set"])
        #expect(library.songs(in: gig.id).isEmpty)
        #expect(library.songs().map(\.title) == ["Wonderwall"])
    }

    @Test func `a Collection Note persists across launches`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let library = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))
        var collection = try library.addCollection(name: "Friday Gig")
        collection.note = "Bring the capo"
        try library.updateCollection(collection)

        let relaunched = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        #expect(relaunched.collections().first?.note == "Bring the capo")
    }

    @Test func `a Collection saved before Collection Notes existed opens with an empty Collection Note`() throws {
        let storeURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        try saveCollectionWithoutNoteAttribute(name: "Friday Gig", to: storeURL)

        let library = PracticeLibrary(container: PersistentStore.container(storeURL: storeURL))

        let collection = try #require(library.collections().first)
        #expect(collection.name == "Friday Gig")
        #expect(collection.note == "")
    }

    private func saveCollectionWithoutNoteAttribute(name: String, to storeURL: URL) throws {
        let attribute = NSAttributeDescription()
        attribute.name = "name"
        attribute.attributeType = .stringAttributeType
        attribute.isOptional = true
        let entity = NSEntityDescription()
        entity.name = "Collection"
        entity.properties = [attribute]
        let model = NSManagedObjectModel()
        model.entities = [entity]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(type: .sqlite, at: storeURL, options: [
            NSPersistentHistoryTrackingKey: true as NSNumber,
        ])
        let context = NSManagedObjectContext(.mainQueue)
        context.persistentStoreCoordinator = coordinator
        let collection = NSManagedObject(entity: entity, insertInto: context)
        collection.setValue(name, forKey: "name")
        try context.save()
    }
}
