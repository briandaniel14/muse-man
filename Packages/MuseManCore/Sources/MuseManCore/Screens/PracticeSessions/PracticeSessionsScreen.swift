import SwiftUI

struct PracticeSessionsScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var isLoggingSession = false
    @State private var openedSession: PracticeSession?

    var body: some View {
        PracticeSessionList(sessions: library.practiceSessions(), openedSession: $openedSession)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Log Practice Session", systemImage: "plus") {
                        isLoggingSession = true
                    }
                }
            }
            .sheet(isPresented: $isLoggingSession) {
                LogPracticeSessionSheet()
            }
            .navigationDestination(item: $openedSession) { session in
                PracticeSessionScreen(session: session)
            }
            .timedPracticeSessionToolbar()
            .paperScreen(title: Destination.practiceSessions.title, isFullWidth: true)
    }
}

struct PracticeSessionList: View {
    let sessions: [PracticeSession]
    @Binding var openedSession: PracticeSession?

    var body: some View {
        List(sessions) { session in
            PracticeSessionRow(session: session)
                .contentShape(.rect)
                .onTapGesture {
                    openedSession = session
                }
                .paperRow()
        }
        .listStyle(.plain)
        #if os(macOS)
            .safeAreaPadding(.top, Theme.listTopInset)
        #endif
            .overlay {
                if sessions.isEmpty {
                    Text("No Practice Sessions yet")
                        .foregroundStyle(Theme.fadedInk)
                }
            }
    }
}

struct PracticeSessionRow: View {
    @Environment(PracticeLibrary.self) private var library
    let session: PracticeSession

    var body: some View {
        HStack(spacing: Theme.rowSpacing) {
            CoverGrid(songs: library.practisedSongs(in: session.id), size: Theme.rowArtworkSize)
            PracticeSessionSummary(session: session)
        }
        .padding(.vertical, 4)
    }
}

struct PracticeSessionSummary: View {
    let session: PracticeSession

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                PracticeSessionNameField(session: session)
                    .font(Theme.body)
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
                    .lineLimit(1)
                if let duration = session.duration {
                    Text(Duration.seconds(duration).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated)))
                        .font(Theme.caption)
                        .foregroundStyle(Theme.fadedInk)
                } else {
                    Text("Running")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.accent)
                }
            }
            if !session.note.isEmpty {
                Text(session.note)
                    .font(Theme.caption)
                    .foregroundStyle(Theme.fadedInk)
            }
        }
    }
}

struct PracticeSessionNameField: View {
    @Environment(PracticeLibrary.self) private var library
    let session: PracticeSession
    @State private var name = ""

    var body: some View {
        TextField("Practice Session name", text: $name, prompt: Text("Untitled").foregroundStyle(Theme.fadedInk))
            .textFieldStyle(.plain)
            .onAppear {
                name = session.name ?? ""
            }
            .onChange(of: name) {
                if name != (session.name ?? "") {
                    try? library.renamePracticeSession(id: session.id, to: name)
                }
            }
    }
}
