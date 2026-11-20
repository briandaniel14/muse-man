import CoreData

public struct Part: Identifiable, Hashable {
    public enum Status: Int16, CaseIterable, Identifiable {
        case wantToLearn
        case learning
        case learned

        public var id: Self {
            self
        }

        public var title: String {
            switch self {
            case .wantToLearn: "Want to learn"
            case .learning: "Learning"
            case .learned: "Learned"
            }
        }
    }

    public let id: NSManagedObjectID
    public let identifier: UUID
    public let song: Song
    public let instrument: Instrument
    public let owner: String
    public var label: String?
    public var status: Status
    public var note: String
    public let dueDate: Date?
}

extension Part {
    init?(_ object: PartObject) {
        guard let identifier = object.identifier, let song = object.song, let instrument = object.instrument else {
            return nil
        }
        id = object.objectID
        self.identifier = identifier
        self.song = Song(song)
        self.instrument = Instrument(instrument)
        owner = object.owner ?? ""
        label = object.label
        status = Status(rawValue: object.status) ?? .wantToLearn
        note = object.note ?? ""
        dueDate = object.dueDate
    }
}
