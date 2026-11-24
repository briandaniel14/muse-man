import Foundation
import MuseManCore

final class TestClock {
    static let start = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 12)) ?? .now

    var now: Date

    init(now: Date = TestClock.start) {
        self.now = now
    }

    func advance(days: Int) {
        now = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
    }
}

extension PracticeLibrary {
    static func inMemory(clock: TestClock = TestClock()) -> PracticeLibrary {
        PracticeLibrary(container: PersistentStore.container(), now: { clock.now })
    }

    func song(id: Song.ID) -> Song? {
        songs().first { $0.id == id }
    }

    func part(id: Part.ID) -> Part? {
        songs().flatMap { parts(of: $0.id) }.first { $0.id == id }
    }
}
