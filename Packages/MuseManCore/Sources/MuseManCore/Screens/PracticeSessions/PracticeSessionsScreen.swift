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
    @Environment(\.self) private var environment
    let sessions: [PracticeSession]

    var body: some View {
        List(sessions) { session in
            NavigationLink(value: session) {
                PracticeSessionRow(session: session)
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Theme.hairline.resolve(in: environment))
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
    let session: PracticeSession

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline) {
                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
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
        .padding(.vertical, 4)
    }
}
