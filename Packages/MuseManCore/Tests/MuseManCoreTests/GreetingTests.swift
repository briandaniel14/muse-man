import MuseManCore
import Testing

struct GreetingTests {
    @Test func `message includes name`() {
        #expect(Greeting.message(for: "world") == "Hello, world!")
    }
}
