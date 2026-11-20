import SwiftUI

struct PartHistorySection: View {
    @Environment(PracticeLibrary.self) private var library
    let partID: Part.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Practice History")
                .font(Theme.title)
                .padding(.bottom, 4)
            Hairline()
            let entries = library.practiceEntries(of: partID)
            if entries.isEmpty {
                Text("Not practised yet")
                    .foregroundStyle(Theme.fadedInk)
                    .padding(.vertical, 12)
            }
            PracticeEntryList(entries: entries, heading: .day)
        }
    }
}
