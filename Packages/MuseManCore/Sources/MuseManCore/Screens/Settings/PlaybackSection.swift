import SwiftUI

struct PlaybackSection: View {
    @SkipIntervalSetting private var skipInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            SectionTitle("Playback")
            Picker("Skip interval", selection: $skipInterval) {
                ForEach(SkipInterval.allCases, id: \.self) { interval in
                    Text("^[\(interval.rawValue) second](inflect: true)")
                        .tag(interval)
                }
            }
            .font(Theme.body)
            .foregroundStyle(Theme.ink)
            .padding(.top, 8)
            Text("How far ← and → jump on the playback bar.")
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
    }
}
