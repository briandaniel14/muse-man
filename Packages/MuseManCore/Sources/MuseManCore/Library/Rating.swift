public enum Rating: Int16, CaseIterable, Identifiable {
    case again = 1
    case hard
    case good
    case easy

    public var id: Self {
        self
    }

    public var title: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }
}
