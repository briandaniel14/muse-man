import SwiftUI

struct SpeedMenu: View {
    @Binding var speed: PlaybackSpeed

    var body: some View {
        Menu {
            Picker("Speed", selection: $speed) {
                ForEach(PlaybackSpeed.all, id: \.self) { speed in
                    Text(speed.percent, format: .percent)
                        .tag(speed)
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label {
                Text(speed.percent, format: .percent)
                    .monospacedDigit()
            } icon: {
                Image(systemName: "gauge.with.needle")
            }
            .labelStyle(.titleAndIcon)
            .font(Theme.caption)
            .foregroundStyle(Theme.accent)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(.rect)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Speed")
        .accessibilityValue(Text(speed.percent, format: .percent))
    }
}
