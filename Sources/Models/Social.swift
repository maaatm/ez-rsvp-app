import Foundation

/// A friend's activity for the social feed (the FOMO engine).
/// Pre-reveal items are themselves mysteries (more FOMO, no spoiler);
/// `revealedEventID` is only set once a friend has shared a revealed adventure.
struct ActivityItem: Identifiable, Hashable {
    var id: String
    var user: AppUser
    var headline: String      // e.g. "said yes to a mystery"
    var detail: String        // e.g. "Friday night · with Rutgers Crew"
    var symbol: String        // SF Symbol
    var revealedEventID: String? // non-nil = a revealed adventure (shareable)
    var timeAgo: String

    var isReveal: Bool { revealedEventID != nil }
}
