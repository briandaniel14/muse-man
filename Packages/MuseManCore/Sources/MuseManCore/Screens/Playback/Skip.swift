import Foundation

public enum SkipInterval: Int, CaseIterable, Sendable {
    case one = 1
    case two = 2
    case five = 5
    case ten = 10
    case fifteen = 15

    public static let standard = SkipInterval.one
}

public enum Skip: Sendable {
    case back
    case forward

    public func time(from time: TimeInterval, by interval: SkipInterval, duration: TimeInterval) -> TimeInterval {
        let step = TimeInterval(interval.rawValue)
        let skipped = self == .back ? time - step : time + step
        return min(max(skipped, 0), duration)
    }
}
