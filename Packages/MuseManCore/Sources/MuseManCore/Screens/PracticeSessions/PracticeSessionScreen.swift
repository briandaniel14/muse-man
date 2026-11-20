import SwiftUI

struct PracticeSessionScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var session: PracticeSession
    @State private var isConfirmingDelete = false
    @State private var isResuming = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                SessionFields(startDate: $session.startDate, minutes: minutes, note: $session.note)
                if session.duration == nil {
                    Button("Resume Practice Session", systemImage: "timer") {
                        isResuming = true
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.accent)
                }
                SessionEntriesSection(sessionID: session.id)
                Button("Delete Practice Session", role: .destructive) {
                    isConfirmingDelete = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, Theme.margin)
            .padding(.bottom, 32)
        }
        .onChange(of: session) {
            try? library.updatePracticeSession(session)
        }
        .onChange(of: isGone) {
            if isGone {
                dismiss()
            }
        }
        .sheet(isPresented: $isResuming) {
            if let current = library.practiceSession(id: session.id) {
                session = current
            }
        } content: {
            TimedPracticeSessionSheet(sessionID: session.id)
        }
        .confirmationDialog(
            "Delete Practice Session?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible,
        ) {
            Button("Delete Practice Session", role: .destructive) {
                try? library.deletePracticeSession(id: session.id)
            }
        } message: {
            Text("Its Practice Entries will be deleted too. Recordings stay on their Parts. This can't be undone.")
        }
        .paperScreen(title: session.startDate.formatted(date: .abbreviated, time: .omitted))
    }

    private var isGone: Bool {
        library.practiceSession(id: session.id) == nil
    }

    private var minutes: Binding<Int?>? {
        guard session.duration != nil else {
            return nil
        }
        return Binding {
            session.duration.map { Int($0 / 60) }
        } set: {
            session.duration = TimeInterval(($0 ?? 0) * 60)
        }
    }
}

struct SessionEntriesSection: View {
    @Environment(PracticeLibrary.self) private var library
    let sessionID: PracticeSession.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Practice Entries")
                .font(Theme.title)
                .padding(.bottom, 4)
            Hairline()
            PracticeEntryList(entries: library.practiceEntries(in: sessionID), heading: .part)
        }
    }
}
