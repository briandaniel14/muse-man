import SwiftUI

struct TimedPracticeSessionToolbar: ViewModifier {
    @Environment(PracticeLibrary.self) private var library
    @State private var session: PracticeSession?

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(title, systemImage: "timer") {
                        session = try? library.startPracticeSession()
                    }
                }
            }
            .sheet(item: $session) { session in
                TimedPracticeSessionSheet(sessionID: session.id)
            }
    }

    private var title: String {
        library.runningPracticeSession() == nil ? "Start Practice Session" : "Resume Practice Session"
    }
}

extension View {
    func timedPracticeSessionToolbar() -> some View {
        modifier(TimedPracticeSessionToolbar())
    }
}
