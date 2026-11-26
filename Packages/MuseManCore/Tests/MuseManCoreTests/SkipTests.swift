import MuseManCore
import Testing

struct SkipTests {
    @Test func `the skip interval choices are 1, 2, 5, 10 and 15 seconds`() {
        #expect(SkipInterval.allCases.map(\.rawValue) == [1, 2, 5, 10, 15])
    }

    @Test func `the skip interval is 1 second until the Musician picks another`() {
        #expect(SkipInterval.standard.rawValue == 1)
    }

    @Test func `skipping forward moves on by the skip interval`() {
        #expect(Skip.forward.time(from: 30, by: .five, duration: 200) == 35)
    }

    @Test func `skipping back moves back by the skip interval`() {
        #expect(Skip.back.time(from: 30, by: .ten, duration: 200) == 20)
    }

    @Test func `skipping back can't go before the start`() {
        #expect(Skip.back.time(from: 3, by: .five, duration: 200) == 0)
    }

    @Test func `skipping forward can't go past the end`() {
        #expect(Skip.forward.time(from: 195, by: .fifteen, duration: 200) == 200)
    }
}
