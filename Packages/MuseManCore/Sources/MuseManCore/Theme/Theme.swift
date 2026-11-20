import SwiftUI

public enum Theme {
    public static let paper = ThemeColor(
        light: Color(red: 0.969, green: 0.953, blue: 0.918),
        dark: Color(red: 0.110, green: 0.102, blue: 0.094),
    )

    public static let ink = ThemeColor(
        light: Color(red: 0.137, green: 0.129, blue: 0.122),
        dark: Color(red: 0.937, green: 0.902, blue: 0.827),
    )

    public static let fadedInk: ThemeColor = ink.opacity(0.6)

    public static let hairline: ThemeColor = ink.opacity(0.15)

    public static let accent = ThemeColor(
        light: Color(red: 0.102, green: 0.478, blue: 0.467),
        dark: Color(red: 0.937, green: 0.502, blue: 0.400),
    )

    public static let largeTitle = Font.custom("DM Serif Display", size: 34, relativeTo: .largeTitle)
    public static let title = Font.custom("DM Serif Display", size: 22, relativeTo: .title2)
    public static let body = Font.custom("DM Sans", size: 17, relativeTo: .body)
    public static let caption = Font.custom("DM Sans", size: 13, relativeTo: .caption)

    public static let margin: CGFloat = 20
}
