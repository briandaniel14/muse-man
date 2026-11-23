import CoreTransferable
import Foundation
import UniformTypeIdentifiers

public struct RecordingFile: Transferable {
    public let audio: Data
    public let fileName: String
    public let contentType: UTType

    public init(audio: Data, name: String? = nil, partName: String, date: Date) {
        self.audio = audio
        contentType = Self.contentType(of: audio)
        let day = date.formatted(Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        let fileExtension = contentType == .mpeg4Audio ? "m4a" : contentType.preferredFilenameExtension ?? "m4a"
        fileName = "\(name ?? "\(partName) \(day)").\(fileExtension)"
    }

    public static func contentType(of audio: Data) -> UTType {
        let bytes = Array(audio.prefix(12))
        func matches(_ text: String, at offset: Int = 0) -> Bool {
            let expected = Array(text.utf8)
            let end = offset + expected.count
            return bytes.count >= end && Array(bytes[offset ..< end]) == expected
        }
        if matches("ftyp", at: 4) {
            return .mpeg4Audio
        }
        if matches("ID3") || bytes.starts(with: [0xFF, 0xFB]) || bytes.starts(with: [0xFF, 0xF3]) {
            return .mp3
        }
        if matches("RIFF"), matches("WAVE", at: 8) {
            return .wav
        }
        if matches("FORM"), matches("AIFF", at: 8) || matches("AIFC", at: 8) {
            return .aiff
        }
        if matches("fLaC"), let flac = UTType("org.xiph.flac") {
            return flac
        }
        return .mpeg4Audio
    }

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .audio) { file in
            let url = URL.temporaryDirectory.appending(path: UUID().uuidString).appending(path: file.fileName)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true,
            )
            try file.audio.write(to: url)
            return SentTransferredFile(url)
        }
    }
}
