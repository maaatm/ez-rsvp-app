import Foundation

/// e-z.rsvp recommendation engine (v1 — heuristic).
///
/// Matches users to events they'll love *without spoiling the surprise*: it
/// scores on metadata the user never sees as "this exact event" — interests,
/// distance, price, difficulty — and surfaces a ranked list of mystery cards.
///
/// Architecture for future AI personalization
/// -------------------------------------------
///  1. FEATURES — each event is a feature vector (interest one-hot, normalized
///     distance/price/difficulty).
///  2. PROFILE  — same shape, learned from explicit interests now and implicit
///     signals later (RSVPs kept, reveals shared, polls voted, no-shows).
///  3. SCORE    — weighted overlap + soft penalties. Swap `score(_:for:)` for an
///     embedding dot-product or an LLM reranker behind the same interface.
///  4. EXPLORE  — a wildcard slot injects novelty so the surprise stays alive.
struct ScoredEvent: Identifiable {
    var id: String { event.id }
    let event: MysteryEvent
    let score: Double      // 0...1
    let reasons: [String]
}

struct RecommendationProfile {
    var interests: [Interest]
    var maxDistance: Double = 25
    var pricePreference: Double = 0.4 // 0 cheap ... 1 splurge
    var adventurousness: Double = 0.6 // 0 chill ... 1 adventurous

    init(user: AppUser) {
        interests = user.interests
        maxDistance = user.radiusMiles
        switch user.budget {
        case .budget: pricePreference = 0.15
        case .moderate: pricePreference = 0.45
        case .premium: pricePreference = 0.85
        }
    }

    init(interests: [Interest], maxDistance: Double = 25,
         pricePreference: Double = 0.4, adventurousness: Double = 0.6) {
        self.interests = interests
        self.maxDistance = maxDistance
        self.pricePreference = pricePreference
        self.adventurousness = adventurousness
    }
}

enum RecommendationEngine {
    private static let wInterest = 0.55
    private static let wDistance = 0.20
    private static let wPrice = 0.10
    private static let wDifficulty = 0.15

    static func score(_ event: MysteryEvent, for profile: RecommendationProfile) -> ScoredEvent {
        var reasons: [String] = []

        // Interest overlap
        let overlap = event.interests.filter { profile.interests.contains($0) }
        let interestScore: Double = profile.interests.isEmpty
            ? 0.5
            : Double(overlap.count) / Double(max(event.interests.count, 1))
        if !overlap.isEmpty {
            reasons.append("Matches your love of \(overlap.map(\.rawValue).joined(separator: " & "))")
        }

        // Distance
        let distanceScore = max(0, 1 - event.distanceMiles / (profile.maxDistance * 1.5))
        if event.distanceMiles <= profile.maxDistance {
            reasons.append("Only \(Int(event.distanceMiles)) miles away")
        }

        // Price fit
        let priceLevel: Double = [PriceTier.budget: 0, .moderate: 0.5, .premium: 1][event.price] ?? 0.5
        let priceScore = 1 - abs(priceLevel - profile.pricePreference)

        // Difficulty fit
        let diffLevel: Double = [Difficulty.beginner: 0, .medium: 0.5, .adventurous: 1][event.difficulty] ?? 0.5
        let diffScore = 1 - abs(diffLevel - profile.adventurousness)
        if event.difficulty == .adventurous && profile.adventurousness > 0.6 {
            reasons.append("Adventurous, just like you")
        }

        let raw = interestScore * wInterest
            + distanceScore * wDistance
            + priceScore * wPrice
            + diffScore * wDifficulty

        if reasons.isEmpty { reasons.append("A fresh pick to expand your horizons") }

        return ScoredEvent(event: event, score: min(1, max(0, raw)), reasons: reasons)
    }

    static func recommend(_ events: [MysteryEvent],
                          for profile: RecommendationProfile,
                          explore: Bool = false) -> [ScoredEvent] {
        var scored = events.map { score($0, for: profile) }
            .sorted { $0.score > $1.score }

        if explore, scored.count > 3 {
            let wildIndex = 2 + (scored.count % 2)
            if wildIndex < scored.count {
                let wild = scored.remove(at: wildIndex)
                let promoted = ScoredEvent(
                    event: wild.event,
                    score: wild.score,
                    reasons: ["Wildcard pick to keep it surprising"] + wild.reasons
                )
                scored.insert(promoted, at: min(1, scored.count))
            }
        }
        return scored
    }
}
