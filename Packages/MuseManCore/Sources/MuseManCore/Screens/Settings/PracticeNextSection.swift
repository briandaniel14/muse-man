import SwiftUI

struct PracticeNextSection: View {
    @Environment(PracticeLibrary.self) private var library
    @PracticeNextSetting private var isPracticeNextOn

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(Destination.practiceNext.title, isOn: $isPracticeNextOn)
                .toggleStyle(.switch)
                .font(Theme.body)
                .foregroundStyle(Theme.ink)
            Text("Suggests which Parts are Due and asks for a Rating each time you log one.")
                .font(Theme.caption)
                .foregroundStyle(Theme.fadedInk)
        }
        .padding(.vertical, 12)
        .onChange(of: isPracticeNextOn) { _, isOn in
            if isOn {
                try? library.makeUnratedPartsDueToday()
            }
        }
    }
}
