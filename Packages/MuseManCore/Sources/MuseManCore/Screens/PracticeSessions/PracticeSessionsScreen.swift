import SwiftUI

struct PracticeSessionsScreen: View {
    @Environment(PracticeLibrary.self) private var library
    @State private var isLoggingSession = false

    var body: some View {
        PracticeSessionList(sessions: library.practiceSessions())
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
            .navigationDestination(for: PracticeSession.self) { session in
                PracticeSessionScreen(session: session)
            }
            .timedPracticeSessionToolbar()
            .paperScreen(title: Destination.practiceSessions.title)
    }
}

struct PracticeSessionList: View {
    let sessions: [PracticeSession]

    var body: some View {
        List(sessions) { session in
            NavigationLink(value: session) {
                PracticeSessionRow(session: session)
            }
            .paperRow()
        }
        .listStyle(.plain)
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
        HStack(spacing: 12) {
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
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.body)
                    .foregroundStyle(Theme.ink)
                Spacer()
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
