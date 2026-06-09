import Foundation
import CoreLocation

struct Clue: Identifiable, Codable, Hashable {
    var id: String
    var text: String
    var symbol: String
    /// Number of days BEFORE the reveal that this clue becomes visible.
    /// e.g. 5 = unlocks when 5 days remain; 0 = unlocks on reveal day.
    var unlocksDaysBefore: Int

    init(id: String = UUID().uuidString, text: String, symbol: String, unlocksDaysBefore: Int) {
        self.id = id
        self.text = text
        self.symbol = symbol
        self.unlocksDaysBefore = unlocksDaysBefore
    }
}

struct Weather: Codable, Hashable {
    var temp: Int
    var condition: String
    var symbol: String // SF Symbol
}

struct MysteryEvent: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var eventDescription: String
    var category: EventCategory
    var difficulty: Difficulty
    var price: PriceTier

    // Hidden until reveal
    var venueName: String
    var generalArea: String
    var latitude: Double
    var longitude: Double

    var eventTime: Date
    var revealTime: Date
    var distanceMiles: Double
    var interests: [Interest]
    var clues: [Clue]
    var weather: Weather?
    var imageSymbol: String // SF Symbol used as hero glyph

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Whole days remaining until the reveal (floored at 0).
    func daysUntilReveal(now: Date = .now) -> Int {
        let secs = revealTime.timeIntervalSince(now)
        return max(0, Int(ceil(secs / 86_400)))
    }

    /// A clue is unlocked once we're within its `unlocksDaysBefore` window.
    func isClueUnlocked(_ clue: Clue, now: Date = .now) -> Bool {
        daysUntilReveal(now: now) <= clue.unlocksDaysBefore || isRevealed(now: now)
    }

    /// Clues the user can currently see, based on time until reveal.
    func unlockedClues(now: Date = .now) -> [Clue] {
        clues.filter { isClueUnlocked($0, now: now) }
    }

    /// Whether the reveal moment has arrived.
    func isRevealed(now: Date = .now) -> Bool { now >= revealTime }

    // Codable: skip computed coordinate
    enum CodingKeys: String, CodingKey {
        case id, title, eventDescription, category, difficulty, price
        case venueName, generalArea, latitude, longitude
        case eventTime, revealTime, distanceMiles, interests, clues, weather, imageSymbol
    }
}
