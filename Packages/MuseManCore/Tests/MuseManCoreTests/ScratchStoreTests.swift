import Foundation
import MuseManCore
import Testing

struct ScratchStoreTests {
    @Test func `the scratch store starts with a few of everything`() {
        let library = PracticeLibrary(container: PersistentStore.scratch())
        let songs = library.songs()
        let parts = songs.flatMap { library.parts(of: $0.id) }

        #expect(songs.count == 6)
        #expect(songs.contains { $0.artworkURL != nil })
        #expect(songs.contains { $0.artworkURL == nil })
        #expect(Set(parts.map(\.status)) == Set(Part.Status.allCases))
        #expect(library.instruments().count == 4)
        #expect(library.collections().count == 3)
        #expect(library.practiceSessions().count == 4)
        #expect(songs.contains { !library.resources(for: $0.id).isEmpty })
        #expect(parts.contains { library.recordings(of: $0.id).count > 1 })
        #expect(!library.practiceNext().isEmpty)
    }
}
