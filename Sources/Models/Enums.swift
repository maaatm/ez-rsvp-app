import SwiftUI

// MARK: - Interest

enum Interest: String, CaseIterable, Codable, Identifiable, Hashable {
    case food = "Food"
    case music = "Music"
    case sports = "Sports"
    case arts = "Arts"
    case comedy = "Comedy"
    case outdoor = "Outdoor Activities"
    case gaming = "Gaming"
    case nightlife = "Nightlife"
    case networking = "Networking"

    var id: String { rawValue }

    /// SF Symbol — never an emoji (icon discipline).
    var symbol: String {
        switch self {
        case .food: return "fork.knife"
        case .music: return "music.note"
        case .sports: return "figure.run"
        case .arts: return "paintpalette.fill"
        case .comedy: return "theatermasks.fill"
        case .outdoor: return "mountain.2.fill"
        case .gaming: return "gamecontroller.fill"
        case .nightlife: return "moon.stars.fill"
        case .networking: return "person.2.fill"
        }
    }
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable, Codable, Identifiable, Hashable {
    case foodAdventure = "Food Adventure"
    case creativeMystery = "Creative Mystery"
    case liveEntertainment = "Live Entertainment"
    case outdoorChallenge = "Outdoor Challenge"
    case socialMixer = "Social Mixer"
    case wellnessEscape = "Wellness Escape"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .foodAdventure: return "takeoutbag.and.cup.and.straw.fill"
        case .creativeMystery: return "paintbrush.pointed.fill"
        case .liveEntertainment: return "music.mic"
        case .outdoorChallenge: return "figure.hiking"
        case .socialMixer: return "sparkles"
        case .wellnessEscape: return "leaf.fill"
        }
    }

    var tint: Color {
        switch self {
        case .foodAdventure: return .orange
        case .creativeMystery: return Theme.fuchsia
        case .liveEntertainment: return Theme.violet
        case .outdoorChallenge: return .green
        case .socialMixer: return Theme.cyan
        case .wellnessEscape: return .mint
        }
    }
}

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Codable, Hashable {
    case beginner = "Beginner Friendly"
    case medium = "Medium Surprise"
    case adventurous = "Adventurous"

    var tint: Color {
        switch self {
        case .beginner: return .green
        case .medium: return .yellow
        case .adventurous: return .pink
        }
    }
}

enum PriceTier: String, CaseIterable, Codable, Hashable {
    case budget = "$"
    case moderate = "$$"
    case premium = "$$$"
}

// MARK: - Preferred Maps App

enum MapsApp: String, CaseIterable, Codable, Identifiable, Hashable {
    case apple = "Apple Maps"
    case google = "Google Maps"
    case waze = "Waze"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .apple: return "map.fill"
        case .google: return "globe.americas.fill"
        case .waze: return "car.fill"
        }
    }
}

// MARK: - RSVP guardrails (dealbreakers)

/// "Tell us what you'd hate" — constraints that shape the match without letting
/// the user pick the event (preserves the surprise).
enum Dealbreaker: String, CaseIterable, Codable, Identifiable, Hashable {
    case indoorOnly = "Indoor only"
    case keepClose = "Keep it close"
    case lowKey = "Low-key only"
    case noLateNight = "No late nights"
    case noLoud = "Nothing too loud"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .indoorOnly: return "house.fill"
        case .keepClose: return "location.fill"
        case .lowKey: return "leaf.fill"
        case .noLateNight: return "moon.zzz.fill"
        case .noLoud: return "speaker.slash.fill"
        }
    }
}

// MARK: - RSVP Status

enum RSVPStatus: String, Codable, Hashable {
    case going
    case maybe
    case pending
    case declined

    var label: String {
        switch self {
        case .going: return "Going"
        case .maybe: return "Maybe"
        case .pending: return "Pending"
        case .declined: return "Declined"
        }
    }

    var symbol: String {
        switch self {
        case .going: return "checkmark.circle.fill"
        case .maybe: return "questionmark.circle.fill"
        case .pending: return "clock.fill"
        case .declined: return "xmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .going: return .green
        case .maybe: return .yellow
        case .pending: return .secondary
        case .declined: return .red
        }
    }
}
