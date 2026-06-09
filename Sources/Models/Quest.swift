import Foundation

/// Guardrail preferences for an RSVP — "tell us what you'd hate," not "pick the
/// event." These shape the match while preserving the surprise.
struct RSVPPreferences: Codable, Hashable {
    var priceCeiling: PriceTier = .premium
    var maxDistance: Double = 25
    var adventurousness: Double = 0.6 // 0 chill … 1 adventurous
    var dealbreakers: Set<Dealbreaker> = []
}

/// A **Quest** — a started mystery RSVP. Links a crew (or a solo user) to a
/// matched mystery event. This is what decouples "having a crew" from
/// "committing to a mystery."
struct Quest: Identifiable, Codable, Hashable {
    var id: String
    var eventID: String
    var crewID: String? // nil = solo
    var ownerID: String
    var status: RSVPStatus
    var preferences: RSVPPreferences
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        eventID: String,
        crewID: String? = nil,
        ownerID: String,
        status: RSVPStatus = .going,
        preferences: RSVPPreferences = .init(),
        createdAt: Date = .now
    ) {
        self.id = id
        self.eventID = eventID
        self.crewID = crewID
        self.ownerID = ownerID
        self.status = status
        self.preferences = preferences
        self.createdAt = createdAt
    }

    var isSolo: Bool { crewID == nil }
}
