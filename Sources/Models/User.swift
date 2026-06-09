import Foundation

struct AppUser: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var email: String
    var photoURL: URL?
    var username: String?       // optional so older saved profiles still decode
    var bio: String?
    var interests: [Interest]
    var city: String
    var budget: PriceTier
    var radiusMiles: Double
    var availability: [String] // e.g. ["Fri", "Sat"]
    var preferredMaps: MapsApp? // optional so older saved profiles still decode
    var isPrivate: Bool?        // when true, only friends can see mysteries/crews

    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        photoURL: URL? = nil,
        username: String? = nil,
        bio: String? = nil,
        interests: [Interest] = [],
        city: String = "New Brunswick, NJ",
        budget: PriceTier = .moderate,
        radiusMiles: Double = 15,
        availability: [String] = ["Fri", "Sat"],
        preferredMaps: MapsApp? = nil,
        isPrivate: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.photoURL = photoURL
        self.username = username
        self.bio = bio
        self.interests = interests
        self.city = city
        self.budget = budget
        self.radiusMiles = radiusMiles
        self.availability = availability
        self.preferredMaps = preferredMaps
        self.isPrivate = isPrivate
    }

    /// Non-optional accessor with a sensible default.
    var mapsApp: MapsApp { preferredMaps ?? .apple }

    var isPrivateProfile: Bool { isPrivate ?? false }

    /// A trimmed bio, or nil when empty — so views can `if let` cleanly.
    var displayBio: String? {
        guard let bio = bio?.trimmingCharacters(in: .whitespacesAndNewlines),
              !bio.isEmpty else { return nil }
        return bio
    }

    /// The @handle to show. Falls back to a name-derived handle so every profile
    /// has one even before the user sets a custom username.
    var handle: String {
        if let username, !username.isEmpty { return username }
        return name.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .joined()
    }

    /// First name for greetings.
    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }

    var initials: String {
        let parts = name.split(separator: " ")
        let chars = parts.prefix(2).compactMap { $0.first }
        return String(chars).uppercased()
    }
}

extension AppUser {
    static let demo = AppUser(
        id: "u1",
        name: "Matt Rivera",
        email: "matt@ezrsvp.app",
        username: "mattr",
        bio: "Always down for whatever. Surprise me.",
        interests: [.food, .music, .gaming, .nightlife],
        city: "New Brunswick, NJ"
    )

    /// Normalizes free text into a valid handle: lowercase, alphanumerics and
    /// underscores only, capped length. Returns nil when nothing is left.
    static func sanitizeUsername(_ raw: String) -> String? {
        let cleaned = raw.lowercased().unicodeScalars.filter {
            CharacterSet.alphanumerics.contains($0) || $0 == "_"
        }
        let result = String(String.UnicodeScalarView(cleaned)).prefix(20)
        return result.isEmpty ? nil : String(result)
    }
}
