import SwiftUI

struct PracticeSessionScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @Environment(\.dismiss) private var dismiss
    @State var session: PracticeSession
    @State private var isConfirmingDelete = false
    @State private var isResuming = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                PracticeSessionHero(session: $session, minutes: minutes)
                PageColumn {
                    SessionEntriesSection(sessionID: session.id)
                }
            }
        }
        .onChange(of: session) {
            try? library.updatePracticeSession(session)
        }
        .toolbar {
            if session.duration == nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("Resume Practice Session", systemImage: "timer") {
                        isResuming = true
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(Theme.bandInk)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            MoreMenu {
                Button("Delete Practice Session", systemImage: "trash", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
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
        .heroScreen(title: session.name ?? session.startDate.formatted(date: .abbreviated, time: .omitted))
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
            SectionTitle("Practice Entries")
                .padding(.bottom, 4)
            Hairline()
            PracticeEntryList(entries: library.practiceEntries(in: sessionID), heading: .part)
        }
    }
}

struct PracticeSessionHero: View {
    @Environment(PracticeLibrary.self) private var library
    @Binding var session: PracticeSession
    let minutes: Binding<Int?>?

    var body: some View {
        ArtworkHero {
            VStack(alignment: .leading, spacing: 8) {
                HeroTextField(label: "Name", placeholder: "Untitled", text: $session.name.orEmpty, axis: .vertical)
                    .font(Theme.heroTitle)
                Text(session.startDate.formatted(date: .long, time: .shortened))
                    .font(Theme.heroSubtitle)
            }
        } panel: {
            HeroPanel {
                HStack(alignment: .top, spacing: 48) {
                    HeroDetail(label: "Started", systemImage: "clock") {
                        DateTimeButton(date: $session.startDate, latest: library.now())
                    }
                    .fixedSize()
                    HeroDetail(label: "Duration", systemImage: "timer") {
                        if let minutes {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                HeroTextField(label: "Minutes", placeholder: "Add", text: minutes.digits)
                                #if os(iOS)
                                    .keyboardType(.numberPad)
                                #endif
                                Text("min")
                                    .font(Theme.caption)
                                    .foregroundStyle(Theme.bandFadedInk)
                            }
                        } else {
                            Text("Running")
                                .foregroundStyle(Theme.highlight)
                        }
                    }
                    .fixedSize()
                }
                HeroDetail(label: "Note", systemImage: "note.text") {
                    HeroTextField(label: "Note", placeholder: "Optional", text: $session.note, axis: .vertical)
                        .lineLimit(2...)
                }
            }
        } artwork: { size in
            CoverGrid(songs: library.practisedSongs(in: session.id), size: size)
        }
    }
}
