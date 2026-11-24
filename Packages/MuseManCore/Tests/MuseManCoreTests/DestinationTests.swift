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

    @Test func `with Practice Next switched off, every destination but Practice Next is visible`() {
        #expect(Destination.visible(isPracticeNextOn: false) == Destination.allCases.filter { $0 != .practiceNext })
        #expect(Destination.visible(isPracticeNextOn: true) == Destination.allCases)
    }

    @Test func `with Practice Next switched off, the app falls back to Library if Practice Next was open`() {
        #expect(Destination.practiceNext.visibleOrFallback(isPracticeNextOn: false) == .library)
        #expect(Destination.practiceNext.visibleOrFallback(isPracticeNextOn: true) == .practiceNext)
        #expect(Destination.collections.visibleOrFallback(isPracticeNextOn: false) == .collections)
    }
}
