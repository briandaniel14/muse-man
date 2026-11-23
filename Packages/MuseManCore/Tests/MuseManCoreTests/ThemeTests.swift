import MuseManCore
import SwiftUI
import Testing

struct ThemeTests {
    private func resolve(_ token: ThemeColor, in scheme: ColorScheme) -> Color.Resolved {
        var environment = EnvironmentValues()
        environment.colorScheme = scheme
        return token.resolve(in: environment).resolve(in: environment)
    }

    @Test func `light paper is white`() {
        let paper = resolve(Theme.paper, in: .light)
        #expect(paper.red > 0.99)
        #expect(paper.green > 0.99)
        #expect(paper.blue > 0.99)
    }

    @Test func `dark mode is dark teal paper with cream ink`() {
        let paper = resolve(Theme.paper, in: .dark)
        let ink = resolve(Theme.ink, in: .dark)
        #expect(paper.red < 0.2)
        #expect(paper.blue > paper.red)
        #expect(ink.blue > 0.75)
        #expect(ink.red > ink.blue)
    }

    @Test func `accent is deep teal in light mode`() {
        let accent = resolve(Theme.accent, in: .light)
        #expect(accent.green > accent.red + 0.15)
        #expect(accent.blue > accent.green)
        #expect(accent.blue < 0.5)
    }

    @Test func `accent is yellow in dark mode`() {
        let accent = resolve(Theme.accent, in: .dark)
        #expect(accent.red > 0.8)
        #expect(accent.green > 0.7)
        #expect(accent.blue < 0.5)
    }

    @Test func `band ink is cream in both modes`() {
        for scheme in [ColorScheme.light, .dark] {
            let ink = resolve(Theme.bandInk, in: scheme)
            #expect(ink.red > 0.9)
            #expect(ink.blue < ink.red)
        }
    }
}
