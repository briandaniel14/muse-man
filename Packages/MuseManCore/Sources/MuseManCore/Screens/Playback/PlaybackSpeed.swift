public struct PlaybackSpeed: Hashable, Sendable {
    public let percent: Int

    public static let normal = PlaybackSpeed(percent: 100)

    public static let all = stride(from: 50, through: 150, by: 5).map(PlaybackSpeed.init)

    public var rate: Float {
        Float(percent) / 100
    }
}
