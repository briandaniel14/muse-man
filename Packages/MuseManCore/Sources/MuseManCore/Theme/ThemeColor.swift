import SwiftUI

public struct ThemeColor: ShapeStyle {
    let light: Color
    let dark: Color

    public func resolve(in environment: EnvironmentValues) -> Color {
        environment.colorScheme == .dark ? dark : light
    }
}
