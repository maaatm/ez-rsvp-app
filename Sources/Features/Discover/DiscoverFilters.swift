import Foundation
import CoreLocation

/// Sort options for the Find Events filter panel (mirrors the web app).
enum DiscoverSort: String, CaseIterable, Identifiable {
    case soonest = "Soonest time"
    case latest = "Latest time"
    case lowest = "Lowest price"
    case highest = "Highest price"

    var id: String { rawValue }

    /// Compact label for the on-screen filter summary chips.
    var short: String {
        switch self {
        case .soonest: return "Soonest"
        case .latest: return "Latest"
        case .lowest: return "Lowest $"
        case .highest: return "Highest $"
        }
    }
}

/// Filter state for Discover's "Find events" surface. These constraints drive
/// which *single* curated mystery is surfaced — there's no browse grid, just the
/// best match within the filters (one curated pick at a time).
struct DiscoverFilters {
    var locationQuery: String = ""
    var selectedLocation: AddressSuggestion? = nil
    var radius: Double = 10            // miles, 1...25
    var maxPrice: Double = 75          // dollars, 0...150
    var sort: DiscoverSort = .soonest
    var categories: Set<EventCategory> = []
    var mysteryMode: Bool = true

    /// Representative ticket price per tier — events model spend as `$ / $$ / $$$`,
    /// so we map to dollars to honor the max-price slider.
    static func dollars(_ tier: PriceTier) -> Int {
        switch tier {
        case .budget: return 30
        case .moderate: return 65
        case .premium: return 110
        }
    }

    /// Applies the hard filters, then ranks with the recommendation engine.
    /// - Radius only bites once an address is chosen (matching the web app:
    ///   "select an address to apply radius filtering").
    /// - Category chips are ignored while Mystery mode is on.
    /// - The chosen sort orders the survivors; the top one is the curated pick.
    func rank(_ events: [MysteryEvent], for profile: RecommendationProfile) -> [ScoredEvent] {
        let candidates = events.filter { event in
            if Self.dollars(event.price) > Int(maxPrice) { return false }
            if !mysteryMode, !categories.isEmpty, !categories.contains(event.category) { return false }
            if let origin = selectedLocation,
               Self.miles(from: origin.coordinate, to: event.coordinate) > radius {
                return false
            }
            return true
        }

        var scored = RecommendationEngine.recommend(candidates, for: profile)
        switch sort {
        case .soonest: scored.sort { $0.event.eventTime < $1.event.eventTime }
        case .latest:  scored.sort { $0.event.eventTime > $1.event.eventTime }
        case .lowest:  scored.sort { Self.dollars($0.event.price) < Self.dollars($1.event.price) }
        case .highest: scored.sort { Self.dollars($0.event.price) > Self.dollars($1.event.price) }
        }
        return scored
    }

    /// Haversine great-circle distance in miles.
    static func miles(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let earthRadius = 3958.8
        let dLat = (to.latitude - from.latitude) * .pi / 180
        let dLng = (to.longitude - from.longitude) * .pi / 180
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2)
        return 2 * earthRadius * asin(min(1, sqrt(a)))
    }
}
