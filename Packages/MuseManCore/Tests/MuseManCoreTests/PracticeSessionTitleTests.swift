import Foundation
import MuseManCore
import Testing

struct PracticeSessionTitleTests {
    @Test func `a named Practice Session is titled with its trimmed name`() throws {
        var session = try PracticeLibrary.inMemory().addPracticeSession(startDate: TestClock.start, duration: 30 * 60)
        session.name = "  Scales warm-up "

        #expect(session.title == "Scales warm-up")
    }

    @Test func `a Practice Session named only with spaces is titled like an unnamed one`() throws {
        var session = try PracticeLibrary.inMemory().addPracticeSession(startDate: TestClock.start, duration: 30 * 60)
        let unnamedTitle = session.title
        session.name = "   "

        #expect(session.title == unnamedTitle)
        #expect(!unnamedTitle.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}
