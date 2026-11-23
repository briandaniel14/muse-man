import Foundation

public struct SongDetails: Equatable {
    public let key: String?
    public let tempo: Int?

    public init(key: String?, tempo: Int?) {
        self.key = key
        self.tempo = tempo
    }
}

public extension SongDetails {
    init?(audioFeatures data: Data, preferring isrcs: [String]) {
        guard
            let tracks = (try? JSONDecoder().decode(AudioFeatures.self, from: data))?.content,
            let track = isrcs.lazy.compactMap({ isrc in tracks.first { $0.isrc == isrc } }).first
        else {
            return nil
        }
        key = Self.keyName(pitchClass: track.key, mode: track.mode)
        tempo = Int(track.tempo.rounded())
    }
}

private extension SongDetails {
    static let majorKeys = ["C", "D♭", "D", "E♭", "E", "F", "F♯", "G", "A♭", "A", "B♭", "B"]
    static let minorKeys = ["C", "C♯", "D", "E♭", "E", "F", "F♯", "G", "G♯", "A", "B♭", "B"]

    static func keyName(pitchClass: Int, mode: Int) -> String? {
        guard majorKeys.indices.contains(pitchClass) else {
            return nil
        }
        return mode == 1 ? "\(majorKeys[pitchClass]) major" : "\(minorKeys[pitchClass]) minor"
    }
}

private struct AudioFeatures: Decodable {
    struct Track: Decodable {
        let isrc: String
        let key: Int
        let mode: Int
        let tempo: Double
    }

    let content: [Track]
}
