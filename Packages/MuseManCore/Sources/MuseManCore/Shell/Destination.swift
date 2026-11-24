public enum Destination: String, CaseIterable, Hashable, Identifiable {
    case practiceNext
    case library
    case collections
    case practiceSessions

    public var id: Self {
        self
    }

    public var title: String {
        switch self {
        case .practiceNext: "Practice Next"
        case .library: "Library"
        case .collections: "Collections"
        case .practiceSessions: "Practice Sessions"
        }
    }

    public var systemImage: String {
        switch self {
        case .practiceNext: "sparkles"
        case .library: "music.note.list"
        case .collections: "rectangle.stack"
        case .practiceSessions: "metronome"
        }
    }
}

public extension Destination {
    static func visible(isPracticeNextOn: Bool) -> [Destination] {
        allCases.filter { isPracticeNextOn || $0 != .practiceNext }
    }

    func visibleOrFallback(isPracticeNextOn: Bool) -> Destination {
        Self.visible(isPracticeNextOn: isPracticeNextOn).contains(self) ? self : .library
    }
}
