import MuseManCore
import SwiftUI
import Testing

struct ThemeTests {
    private func resolve(_ token: ThemeColor, in scheme: ColorScheme) -> Color.Resolved {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        return token.resolve(in: environment).resolve(in: environment)
    }

    @Test func `light paper is a warm off-white`() {
        let paper = resolve(Theme.paper, in: .light)
        #expect(paper.blue > 0.85)
        #expect(paper.blue < 1)
        #expect(paper.red > paper.blue)
    }

    @Test func `dark mode is dark paper with cream ink`() {
        let paper = resolve(Theme.paper, in: .dark)
        let ink = resolve(Theme.ink, in: .dark)
        #expect(paper.red < 0.2)
        #expect(ink.blue > 0.75)
        #expect(ink.red > ink.blue)
    }

    @Test func `accent is teal in light mode`() {
        let accent = resolve(Theme.accent, in: .light)
        #expect(accent.green > accent.red + 0.2)
        #expect(abs(accent.green - accent.blue) < 0.1)
    }

    @Test func `accent is soft orange-red in dark mode`() {
        let accent = resolve(Theme.accent, in: .dark)
        #expect(accent.red > 0.8)
        #expect(accent.red > accent.green + 0.2)
        #expect(accent.green > accent.blue)
    }
}
