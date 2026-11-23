import SwiftUI

public struct Hairline: View {
    @Environment(\.displayScale) private var displayScale

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(height: 1 / displayScale)
    }
}

public struct VerticalHairline: View {
    @Environment(\.displayScale) private var displayScale

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Theme.hairline)
            .frame(width: 1 / displayScale)
            .ignoresSafeArea()
    }
}
