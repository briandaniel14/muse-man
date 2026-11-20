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
