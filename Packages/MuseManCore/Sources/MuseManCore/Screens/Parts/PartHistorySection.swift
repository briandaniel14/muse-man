import SwiftUI

struct PartHistorySection: View {
    @Environment(PracticeLibrary.self) private var library
    let partID: Part.ID
    @AppStorage("showsPartPracticeHistory") private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleSectionHeader(title: "Practice History", isExpanded: $isExpanded)
            if isExpanded {
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
}
