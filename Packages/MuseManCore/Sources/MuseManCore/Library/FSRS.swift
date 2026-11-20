import Foundation

struct FSRS {
    static let weights = [
        0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046, 1.54575,
        0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315, 2.9898, 0.51655, 0.6621,
    ]
    static let decay = -0.5
    static let factor = 19.0 / 81.0
    static let maximumInterval = 36500

    private(set) var stability: Double
    private(set) var difficulty: Double

    init(rating: Rating) {
        stability = Self.weights[Int(rating.rawValue) - 1]
        difficulty = Self.initialDifficulty(rating)
    }

    var interval: Int {
        min(max(Int(stability.rounded()), 1), Self.maximumInterval)
    }

    mutating func review(_ rating: Rating, after elapsedDays: Int) {
        let retrievability = pow(1 + Self.factor * Double(elapsedDays) / stability, Self.decay)
        stability = rating == .again
            ? forgetStability(retrievability)
            : recallStability(rating, retrievability)
        difficulty = nextDifficulty(rating)
    }

    private func recallStability(_ rating: Rating, _ retrievability: Double) -> Double {
        let weight = Self.weights
        let hardPenalty = rating == .hard ? weight[15] : 1
        let easyBonus = rating == .easy ? weight[16] : 1
        return stability * (1 + exp(weight[8]) * (11 - difficulty) * pow(stability, -weight[9])
            * (exp((1 - retrievability) * weight[10]) - 1) * hardPenalty * easyBonus)
    }

    private func forgetStability(_ retrievability: Double) -> Double {
        let weight = Self.weights
        let forgotten = weight[11] * pow(difficulty, -weight[12]) * (pow(stability + 1, weight[13]) - 1)
            * exp((1 - retrievability) * weight[14])
        return min(forgotten, stability / exp(weight[17] * weight[18]))
    }

    private func nextDifficulty(_ rating: Rating) -> Double {
        let weight = Self.weights
        let change = -weight[6] * (Double(rating.rawValue) - 3)
        let damped = difficulty + change * (10 - difficulty) / 9
        return Self.clamp(weight[7] * Self.initialDifficulty(.easy) + (1 - weight[7]) * damped)
    }

    private static func initialDifficulty(_ rating: Rating) -> Double {
        clamp(weights[4] - exp(weights[5] * (Double(rating.rawValue) - 1)) + 1)
    }

    private static func clamp(_ difficulty: Double) -> Double {
        min(max(difficulty, 1), 10)
    }
}
