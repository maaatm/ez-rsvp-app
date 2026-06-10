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

    /// Whole days remaining until the event itself begins (floored at 0).
    func daysUntilEvent(now: Date = .now) -> Int {
        let secs = eventTime.timeIntervalSince(now)
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

    /// A real, venue-related photo for the reveal hero. We don't ship bundled
    /// venue photography, so each event resolves its hero glyph (falling back to
    /// category) to a curated, content-matched photo on Wikimedia Commons' CDN —
    /// stable URLs, fast delivery, and a known subject (so e.g. cosmic bowling
    /// shows an actual indoor bowling alley). Callers fall back to `imageSymbol`
    /// if it can't load.
    var heroImageURL: URL? {
        let path: String
        switch imageSymbol {
        case "figure.bowling": path = Self.img.bowling
        case "takeoutbag.and.cup.and.straw.fill": path = Self.img.streetFood
        case "paintbrush.pointed.fill", "paintbrush.fill": path = Self.img.studio
        case "figure.hiking": path = Self.img.hiking
        case "music.mic": path = Self.img.concert
        case "gamecontroller.fill": path = Self.img.arcade
        case "leaf.fill": path = Self.img.forest
        case "theatermasks.fill": path = Self.img.theater
        case "fork.knife.circle.fill": path = Self.img.restaurant
        case "questionmark.bubble.fill": path = Self.img.bar
        case "sailboat.fill": path = Self.img.kayak
        default: path = categoryImagePath
        }
        return URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/" + path)
    }

    /// Fallback photo when the hero glyph isn't one we've mapped.
    private var categoryImagePath: String {
        switch category {
        case .foodAdventure: return Self.img.restaurant
        case .creativeMystery: return Self.img.studio
        case .liveEntertainment: return Self.img.concert
        case .outdoorChallenge: return Self.img.hiking
        case .socialMixer: return Self.img.bar
        case .wellnessEscape: return Self.img.forest
        }
    }

    /// Wikimedia Commons thumbnail paths (everything after `/commons/thumb/`),
    /// each verified to resolve to a content-matching photo.
    private enum img {
        static let bowling = "c/c6/Bowling_Alley_Pelixir_Oulu_20150110.JPG/960px-Bowling_Alley_Pelixir_Oulu_20150110.JPG"
        static let streetFood = "1/13/Reffen_Copenhagen_Street_Food_Market.jpg/960px-Reffen_Copenhagen_Street_Food_Market.jpg"
        static let studio = "1/18/Okopod_-_Pottery_Studio.jpg/960px-Okopod_-_Pottery_Studio.jpg"
        static let hiking = "f/f1/Hiking_trail_at_N%C3%A1mafjall_Mountain%2C_Iceland%2C_20240716_1137_1368.jpg/960px-Hiking_trail_at_N%C3%A1mafjall_Mountain%2C_Iceland%2C_20240716_1137_1368.jpg"
        static let concert = "c/cc/Heritage_Live_concert_crowd_and_stage_at_Sandringham_2023_-_geograph.org.uk_-_7586057.jpg/960px-Heritage_Live_concert_crowd_and_stage_at_Sandringham_2023_-_geograph.org.uk_-_7586057.jpg"
        static let arcade = "5/5d/Dave_%26_Buster%27s_video_arcade_in_Columbus%2C_OH_-_17912.JPG/960px-Dave_%26_Buster%27s_video_arcade_in_Columbus%2C_OH_-_17912.JPG"
        static let forest = "7/72/Forest_path_through_a_deciduous_forest_in_spring%2C_Finland.jpg/960px-Forest_path_through_a_deciduous_forest_in_spring%2C_Finland.jpg"
        static let theater = "7/70/Katowice_Silesian_Theatre_auditorium_2022.jpg/960px-Katowice_Silesian_Theatre_auditorium_2022.jpg"
        static let restaurant = "5/58/Table_set_for_dining_in_a_modern_restaurant_interior_with_wooden_walls_and_elegant_decor.jpg/960px-Table_set_for_dining_in_a_modern_restaurant_interior_with_wooden_walls_and_elegant_decor.jpg"
        static let bar = "0/03/Bar_in_Bristol.jpg/960px-Bar_in_Bristol.jpg"
        static let kayak = "8/89/Kayaking_trip_on_the_Bobr_River%2C_Belarus.jpg/960px-Kayaking_trip_on_the_Bobr_River%2C_Belarus.jpg"
    }

    // Codable: skip computed coordinate
    enum CodingKeys: String, CodingKey {
        case id, title, eventDescription, category, difficulty, price
        case venueName, generalArea, latitude, longitude
        case eventTime, revealTime, distanceMiles, interests, clues, weather, imageSymbol
    }
}
