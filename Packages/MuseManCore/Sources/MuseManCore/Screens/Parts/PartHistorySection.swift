import SwiftUI

struct PartHistorySection: View {
    @Environment(PracticeLibrary.self) private var library
    let part: Part
    @State private var isLoggingSession = false
    @AppStorage("showsPartPracticeHistory") private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleSectionHeader(title: "Practice History", isExpanded: $isExpanded) {
                Button("Log Practice Session", systemImage: "plus") {
                    isLoggingSession = true
                }
                .modifier(SectionHeaderAction())
            }
            if isExpanded {
                let entries = library.practiceEntries(of: part.id)
                if entries.isEmpty {
                    Text("Not practised yet")
                        .foregroundStyle(Theme.fadedInk)
                        .padding(.vertical, 12)
                }
                PracticeEntryList(entries: entries, heading: .day)
            }
        }
        .sheet(isPresented: $isLoggingSession) {
            LogPracticeSessionSheet(drafts: [PracticeEntryDraft(part: part)])
        }
    }
}
