import MuseManCore
import Testing

struct DestinationTests {
    @Test func `top-level destinations in screen map order`() {
        #expect(Destination.allCases.map(\.title) == [
            "Practice Next",
            "Library",
            "Collections",
            "Practice Sessions",
        ])
    }

    @Test func `with Practice Next switched off, every destination but Practice Next is shown`() {
        #expect(Destination.shown(isPracticeNextOn: false) == Destination.allCases.filter { $0 != .practiceNext })
        #expect(Destination.shown(isPracticeNextOn: true) == Destination.allCases)
    }

    @Test func `with Practice Next switched off, the app lands on Library if Practice Next was open`() {
        #expect(Destination.practiceNext.landing(isPracticeNextOn: false) == .library)
        #expect(Destination.practiceNext.landing(isPracticeNextOn: true) == .practiceNext)
        #expect(Destination.collections.landing(isPracticeNextOn: false) == .collections)
    }
}
