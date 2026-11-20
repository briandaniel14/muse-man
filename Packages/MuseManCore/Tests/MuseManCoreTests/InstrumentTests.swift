import MuseManCore
import Testing

struct InstrumentTests {
    @Test func `created Instruments are offered by name`() throws {
        let library = PracticeLibrary.inMemory()

        try library.addInstrument(name: "Piano")
        try library.addInstrument(name: "bass")
        try library.addInstrument(name: "Guitar")

        #expect(library.instruments().map(\.name) == ["bass", "Guitar", "Piano"])
    }
}
