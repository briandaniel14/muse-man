import SwiftUI

struct CollapsibleSectionHeader<Accessory: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                SectionTitle(title)
                Spacer()
                if isExpanded {
                    accessory
                }
                Button(isExpanded ? "Hide \(title)" : "Show \(title)", systemImage: "chevron.up") {
                    withAnimation(.snappy) {
                        isExpanded.toggle()
                    }
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
                .foregroundStyle(Theme.accent)
                .rotationEffect(.degrees(isExpanded ? 0 : 180))
            }
            .padding(.bottom, 4)
            Hairline()
        }
    }
}

extension CollapsibleSectionHeader where Accessory == EmptyView {
    init(title: String, isExpanded: Binding<Bool>) {
        self.init(title: title, isExpanded: isExpanded) {
            EmptyView()
        }
    }
}
