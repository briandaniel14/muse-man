import AVFoundation
import Observation

@Observable final class AudioRecorder {
    private(set) var isRecording = false
    @ObservationIgnored private var recorder: AVAudioRecorder?

    var currentTime: TimeInterval {
        recorder?.currentTime ?? 0
    }

    func start() async throws {
        _ = await AVAudioApplication.requestRecordPermission()
        #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        #endif
        let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).m4a")
        let recorder = try AVAudioRecorder(url: url, settings: [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ])
        recorder.record()
        self.recorder = recorder
        isRecording = true
    }

    func stop() throws -> Data? {
        guard let recorder else {
            return nil
        }
        recorder.stop()
        let data = try Data(contentsOf: recorder.url)
        discard()
        return data
    }

    func discard() {
        recorder?.stop()
        recorder?.deleteRecording()
        recorder = nil
        isRecording = false
    }
}
