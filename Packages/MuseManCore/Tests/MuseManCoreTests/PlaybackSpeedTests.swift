import MuseManCore
import Testing

struct PlaybackSpeedTests {
    @Test func `the speed runs from 50% to 150% in 5% steps`() {
        #expect(PlaybackSpeed.all.map(\.percent) == [
            50, 55, 60, 65, 70, 75, 80, 85, 90, 95,
            100,
            105, 110, 115, 120, 125, 130, 135, 140, 145, 150,
        ])
    }

    @Test func `the speed starts at 100%`() {
        #expect(PlaybackSpeed.normal.percent == 100)
    }

    @Test func `a speed plays at that share of normal speed`() {
        #expect(PlaybackSpeed.all.first?.rate == 0.5)
        #expect(PlaybackSpeed.normal.rate == 1)
        #expect(PlaybackSpeed.all.last?.rate == 1.5)
    }
}
