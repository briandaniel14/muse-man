import MuseManCore
import Testing

struct DestinationTests {
    @Test func `top-level destinations in screen map order`() {
        #expect(Destination.allCases.map(\.title) == [
            "Practice Next",
            "Library",
            "Parts",
            "Collections",
            "Practice Sessions",
        ])
    }
}
