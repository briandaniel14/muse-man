import CoreText
import MuseManCore
import Testing

struct FontsTests {
    @Test func `registers DM Sans and DM Serif Display`() {
        Fonts.register()
        let families = CTFontManagerCopyAvailableFontFamilyNames() as? [String] ?? []
        #expect(families.contains("DM Sans"))
        #expect(families.contains("DM Serif Display"))
    }
}
