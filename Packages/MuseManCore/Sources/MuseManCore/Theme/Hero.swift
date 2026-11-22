import SwiftUI

struct Hero<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            content
        }
        .textFieldStyle(.plain)
        .foregroundStyle(Theme.bandInk)
        .tint(Theme.bandSelection)
        .padding(.horizontal, Theme.margin)
        .padding(.top, 16)
        .padding(.bottom, 32)
        .frame(maxWidth: Theme.readableWidth, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.band)
    }
}

struct HeroTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var axis = Axis.horizontal

    var body: some View {
        TextField(text: $text, prompt: Text(placeholder).foregroundStyle(Theme.bandFadedInk), axis: axis) {
            Text(label)
        }
        .environment(\.colorScheme, .dark)
    }
}

struct HeroChip: View {
    let title: String
    var isSelected = false

    var body: some View {
        Text(title)
            .font(Theme.caption)
            .foregroundStyle(isSelected ? Theme.band : Theme.highlight)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Theme.highlight : Theme.clear, in: .rect(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Theme.highlight, lineWidth: 1)
            }
    }
}

struct HeroPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.bandPanel, in: .rect(cornerRadius: 12))
    }
}

struct HeroDetail<Content: View>: View {
    let label: String
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(label)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.bandFadedInk)
                Image(systemName: systemImage)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.highlight)
            }
            content
                .font(Theme.body)
                .foregroundStyle(Theme.bandInk)
        }
    }
}
