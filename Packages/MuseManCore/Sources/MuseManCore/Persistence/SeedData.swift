import CoreData

enum SeedData {
    private static let artworkHost = "https://is1-ssl.mzstatic.com/image/thumb/"
    private static let appleMusicAlbums = "https://music.apple.com/us/album/"

    static func fill(_ container: NSPersistentContainer, today: Date = Calendar.current.startOfDay(for: .now)) {
        let library = PracticeLibrary(container: container, now: { today })
        let songs = addSongs(to: library)
        let parts = addParts(to: library, songs: songs)
        addResources(to: library, songs: songs)
        addCollections(to: library, songs: songs)
        addRecordings(to: library, parts: parts, today: today)
        addPractice(to: container, parts: parts, today: today)
    }

    static func tone(frequency: Double, seconds: Double = 2) -> Data {
        let rate = 8000
        var samples = Data()
        for index in 0 ..< Int(Double(rate) * seconds) {
            let value = Int16(sin(2 * .pi * frequency * Double(index) / Double(rate)) * 6000)
            withUnsafeBytes(of: value.littleEndian) { samples.append(contentsOf: $0) }
        }
        var data = Data("RIFF".utf8)
        func append(_ value: some FixedWidthInteger) {
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
        }
        append(UInt32(36 + samples.count))
        data.append(Data("WAVEfmt ".utf8))
        append(UInt32(16))
        append(UInt16(1))
        append(UInt16(1))
        append(UInt32(rate))
        append(UInt32(rate * 2))
        append(UInt16(2))
        append(UInt16(16))
        data.append(Data("data".utf8))
        append(UInt32(samples.count))
        data.append(samples)
        return data
    }

    private static func addSongs(to library: PracticeLibrary) -> [String: Song.ID] {
        var songs: [String: Song.ID] = [:]
        func add(
            _ title: String,
            _ artist: String,
            key: String? = nil,
            tempo: Int? = nil,
            artwork: String? = nil,
            appleMusic: (id: String, album: String)? = nil,
        ) {
            songs[title] = try? library.addSong(
                title: title,
                artist: artist,
                key: key,
                tempo: tempo,
                artworkURL: artwork.flatMap { URL(string: "\(artworkHost)\($0)/600x600bb.jpg") },
                appleMusicSong: appleMusic.flatMap { song in
                    URL(string: "\(appleMusicAlbums)\(song.album)?i=\(song.id)").map {
                        AppleMusicSong(id: song.id, url: $0)
                    }
                },
            ).id
        }
        add(
            "Smells Like Teen Spirit", "Nirvana", key: "F minor", tempo: 117,
            artwork: "Music115/v4/95/fd/b9/95fdb9b2-6d2b-92a6-97f2-51c1a6d77f1a/00602527874609.rgb.jpg",
            appleMusic: ("1440783625", "smells-like-teen-spirit/1440783617"),
        )
        add(
            "Wonderwall", "Oasis", key: "F♯ minor", tempo: 87,
            artwork: "Music113/v4/04/92/e0/0492e08b-cbcc-9969-9ad6-8f5a0888068c/5051961007107.jpg",
            appleMusic: ("1517447333", "wonderwall/1517447039"),
        )
        add(
            "Blackbird", "The Beatles", key: "G major", tempo: 94,
            artwork: "Music115/v4/fa/5b/89/fa5b898d-bad6-e053-4195-260e5c74f2bb/00602567725466.rgb.jpg",
            appleMusic: ("1441133834", "blackbird/1441133180"),
        )
        add(
            "Hotel California", "Eagles", key: "B minor", tempo: 74,
            artwork: "Music115/v4/88/16/2c/88162c3d-46db-8321-61f3-3a47404cfe76/075596050920.jpg",
            appleMusic: ("635770202", "hotel-california/635770200"),
        )
        add("Alien", "Manchester Orchestra", key: "A", tempo: 100)
        add("Untitled Riff", "Me")
        return songs
    }

    private static func addParts(to library: PracticeLibrary, songs: [String: Song.ID]) -> [String: Part.ID] {
        var instruments: [String: Instrument.ID] = [:]
        for name in ["Guitar", "Bass", "Piano", "Vocals", "Drums"] {
            instruments[name] = try? library.addInstrument(name: name).id
        }
        var parts: [String: Part.ID] = [:]
        func add(
            _ name: String,
            _ song: String,
            _ instrument: String,
            label: String? = nil,
            status: Part.Status = .wantToLearn,
            note: String = "",
        ) {
            guard let song = songs[song],
                  let instrument = instruments[instrument],
                  var part = try? library.addPart(to: song, instrument: instrument, label: label)
            else {
                return
            }
            part.status = status
            part.note = note
            try? library.updatePart(part)
            parts[name] = part.id
        }
        add("riff", "Smells Like Teen Spirit", "Guitar", label: "riff", status: .learning, note: "Palm mute the verse")
        add("teen spirit bass", "Smells Like Teen Spirit", "Bass", label: "verse")
        add("strumming", "Wonderwall", "Guitar", label: "rhythm", status: .learning)
        add("wonderwall vocals", "Wonderwall", "Vocals")
        add(
            "fingerpicking", "Blackbird", "Guitar", label: "fingerpicking", status: .learning,
            note: "Thumb on the bass string, index and middle together",
        )
        add("solo", "Hotel California", "Guitar", label: "solo")
        add("hotel bass", "Hotel California", "Bass", status: .learning)
        add("alien piano", "Alien", "Piano", status: .learned, note: "Sustain through the chorus")
        return parts
    }

    private static func addResources(to library: PracticeLibrary, songs: [String: Song.ID]) {
        func add(_ song: String, _ url: String, title: String? = nil) {
            if let song = songs[song], let url = URL(string: url) {
                _ = try? library.addResource(url: url, title: title, to: song)
            }
        }
        add("Smells Like Teen Spirit", "https://www.youtube.com/watch?v=hTWKbfoikeg", title: "Music Video")
        add(
            "Smells Like Teen Spirit",
            "https://www.songsterr.com/a/wsa/nirvana-smells-like-teen-spirit-tab-s269",
            title: "Tabs",
        )
        add("Blackbird", "https://www.youtube.com/watch?v=Man4Xw8Xypo")
    }

    private static func addCollections(to library: PracticeLibrary, songs: [String: Song.ID]) {
        func add(_ name: String, _ titles: [String]) {
            guard let collection = try? library.addCollection(name: name) else {
                return
            }
            for song in titles.compactMap({ songs[$0] }) {
                try? library.addSong(song, to: collection.id)
            }
        }
        add("Campfire", ["Wonderwall", "Blackbird"])
        add("Band Set", ["Smells Like Teen Spirit", "Hotel California", "Alien"])
        add("Someday", [])
        add("Encore", ["Hotel California"])
        add("Full Set", ["Smells Like Teen Spirit", "Wonderwall", "Blackbird", "Hotel California", "Alien"])
    }

    private static func addRecordings(to library: PracticeLibrary, parts: [String: Part.ID], today: Date) {
        func add(_ part: String, frequency: Double, daysAgo: Int) {
            if let part = parts[part] {
                let date = day(-daysAgo, of: today)
                _ = try? library.addRecording(audio: tone(frequency: frequency), date: date, to: part)
            }
        }
        add("riff", frequency: 220, daysAgo: 6)
        add("fingerpicking", frequency: 330, daysAgo: 10)
        add("fingerpicking", frequency: 392, daysAgo: 3)
    }

    private static func addPractice(to container: NSPersistentContainer, parts: [String: Part.ID], today: Date) {
        func session(daysAgo: Int, minutes: Double, note: String = "", entries: (Entries) -> Void) {
            let date = day(-daysAgo, of: today)
            let library = PracticeLibrary(container: container, now: { date })
            if let session = try? library.addPracticeSession(startDate: date, duration: minutes * 60, note: note) {
                entries(Entries(library: library, session: session.id, parts: parts))
            }
        }
        session(daysAgo: 10, minutes: 40, note: "Slow and steady") {
            $0.add("fingerpicking", .hard, note: "Lost it in the bridge")
            $0.add("strumming", .good)
        }
        session(daysAgo: 6, minutes: 25) {
            $0.add("riff", .again, note: "Verse mutes too loud", attachingLatestRecording: true)
            $0.add("hotel bass", .good)
        }
        session(daysAgo: 3, minutes: 50, note: "Good energy today") {
            $0.add("fingerpicking", .good)
            $0.add("riff", .hard)
            $0.add("strumming", .easy)
        }
        session(daysAgo: 1, minutes: 15) {
            $0.add("hotel bass", .again, note: "Walk-up into the chorus")
            $0.add("alien piano", nil, note: "Played it through once")
        }
    }

    private static func day(_ offset: Int, of today: Date) -> Date {
        Calendar.current.date(byAdding: DateComponents(day: offset, hour: 18), to: today) ?? today
    }

    private struct Entries {
        let library: PracticeLibrary
        let session: PracticeSession.ID
        let parts: [String: Part.ID]

        func add(_ part: String, _ rating: Rating?, note: String = "", attachingLatestRecording: Bool = false) {
            guard let part = parts[part] else {
                return
            }
            _ = try? library.addPracticeEntry(
                to: session,
                part: part,
                rating: rating,
                note: note,
                recordingID: attachingLatestRecording ? library.recordings(of: part).first?.identifier : nil,
            )
        }
    }
}
