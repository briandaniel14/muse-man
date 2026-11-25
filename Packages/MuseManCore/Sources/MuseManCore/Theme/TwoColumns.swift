import SwiftUI

struct TwoColumns<Leading: View, Trailing: View>: View {
    @ViewBuilder let leading: Leading
    @ViewBuilder let trailing: Trailing

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 48) {
                column { leading }
                    .frame(minWidth: 340)
                column { trailing }
                    .frame(minWidth: 300)
            }
            column {
                leading
                trailing
            }
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.paper)
    }

    private func column(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 40) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PageColumn<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            content
        }
        .padding(.horizontal, Theme.margin)
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.paper)
    }
}
