import SwiftUI

public enum Theme {
    public static let paper = ThemeColor(
        light: Color(red: 1, green: 1, blue: 1),
        dark: Color(red: 0.067, green: 0.129, blue: 0.145),
    )

    public static let sidebar = ThemeColor(
        light: Color(red: 0.969, green: 0.961, blue: 0.941),
        dark: Color(red: 0.090, green: 0.165, blue: 0.184),
    )

    public static let ink = ThemeColor(
        light: Color(red: 0.169, green: 0.208, blue: 0.220),
        dark: Color(red: 0.957, green: 0.925, blue: 0.839),
    )

    public static let fadedInk: ThemeColor = ink.opacity(0.62)

    public static let hairline: ThemeColor = ink.opacity(0.18)

    public static let heading = ThemeColor(
        light: Color(red: 0.180, green: 0.373, blue: 0.420),
        dark: Color(red: 0.984, green: 0.945, blue: 0.812),
    )

    public static let accent = ThemeColor(
        light: Color(red: 0.180, green: 0.373, blue: 0.420),
        dark: Color(red: 0.929, green: 0.835, blue: 0.455),
    )

    public static let band = ThemeColor(
        light: Color(red: 0.180, green: 0.373, blue: 0.420),
        dark: Color(red: 0.122, green: 0.255, blue: 0.290),
    )

    public static let bandPanel = ThemeColor(
        light: Color(red: 0.161, green: 0.325, blue: 0.369),
        dark: Color(red: 0.094, green: 0.208, blue: 0.239),
    )

    public static let bandInk = ThemeColor(
        light: Color(red: 0.984, green: 0.945, blue: 0.812),
        dark: Color(red: 0.984, green: 0.945, blue: 0.812),
    )

    public static let bandFadedInk: ThemeColor = bandInk.opacity(0.75)

    public static let selection: ThemeColor = accent.opacity(0.12)

    public static let bandSelection = ThemeColor(
        light: Color(red: 0.365, green: 0.580, blue: 0.639),
        dark: Color(red: 0.365, green: 0.580, blue: 0.639),
    )

    public static let clear = ThemeColor(light: .clear, dark: .clear)

    public static let highlight = ThemeColor(
        light: Color(red: 0.929, green: 0.835, blue: 0.455),
        dark: Color(red: 0.929, green: 0.835, blue: 0.455),
    )

    public static let heroTitle = Font.custom("DM Serif Display", size: 48, relativeTo: .largeTitle)
    public static let heroSubtitle = Font.custom("DM Sans", size: 22, relativeTo: .title3)
    public static let largeTitle = Font.custom("DM Serif Display", size: 34, relativeTo: .largeTitle)
    public static let title = Font.custom("DM Serif Display", size: 22, relativeTo: .title2)
    public static let body = Font.custom("DM Sans", size: 17, relativeTo: .body)
    public static let caption = Font.custom("DM Sans", size: 13, relativeTo: .caption)

    public static let margin: CGFloat = 20
    public static let readableWidth: CGFloat = 960
    public nonisolated static let wideHeroWidth: CGFloat = 640
    public static let heroArtworkSize: CGFloat = 200
    public static let compactHeroArtworkSize: CGFloat = 120
}
