import Foundation

/// Demo seed data, mirrored in firestore-schema.md. Times are relative to now
/// so the live demo always shows realistic upcoming events + a near-term reveal.
enum SampleData {
    private static let hour: TimeInterval = 3_600
    private static let day: TimeInterval = 86_400

    static func events(now: Date = .now) -> [MysteryEvent] {
        [
            MysteryEvent(
                id: "e1",
                title: "Cosmic Bowling Night",
                eventDescription: "Glow-in-the-dark lanes, neon cocktails, and a private VIP section reserved just for your crew. Fog machines, a live DJ spinning throwbacks, and a secret high-score prize.",
                category: .liveEntertainment,
                difficulty: .beginner,
                price: .moderate,
                venueName: "Bowlero North Brunswick",
                generalArea: "North Brunswick, NJ",
                latitude: 40.4501, longitude: -74.4846,
                eventTime: now.addingTimeInterval(2 * day + 19 * hour),
                revealTime: now.addingTimeInterval(2 * day),
                distanceMiles: 8,
                interests: [.gaming, .music, .food],
                clues: [
                    Clue(text: "It's indoors", symbol: "house.fill", unlocksDaysBefore: 5),
                    Clue(text: "Within 15 miles", symbol: "location.fill", unlocksDaysBefore: 5),
                    Clue(text: "Food & drinks involved", symbol: "fork.knife", unlocksDaysBefore: 3),
                    Clue(text: "Things will glow", symbol: "sparkles", unlocksDaysBefore: 1),
                    Clue(text: "Friendly competition", symbol: "trophy.fill", unlocksDaysBefore: 0)
                ],
                weather: Weather(temp: 64, condition: "Clear night", symbol: "moon.stars.fill"),
                imageSymbol: "figure.bowling"
            ),
            MysteryEvent(
                id: "e2",
                title: "Secret Ramen Crawl",
                eventDescription: "Three hidden ramen counters, one night. A guided tasting through the city's best-kept noodle secrets, ending at a speakeasy dessert bar.",
                category: .foodAdventure,
                difficulty: .medium,
                price: .moderate,
                venueName: "Downtown Tasting Route",
                generalArea: "New Brunswick, NJ",
                latitude: 40.4862, longitude: -74.4518,
                eventTime: now.addingTimeInterval(5 * day + 18 * hour),
                revealTime: now.addingTimeInterval(5 * day),
                distanceMiles: 4,
                interests: [.food],
                clues: [
                    Clue(text: "Come hungry", symbol: "fork.knife", unlocksDaysBefore: 5),
                    Clue(text: "Walkable route", symbol: "figure.walk", unlocksDaysBefore: 3),
                    Clue(text: "Within 10 miles", symbol: "location.fill", unlocksDaysBefore: 1)
                ],
                weather: Weather(temp: 58, condition: "Crisp", symbol: "wind"),
                imageSymbol: "takeoutbag.and.cup.and.straw.fill"
            ),
            MysteryEvent(
                id: "e3",
                title: "Underground Paint Jam",
                eventDescription: "A canvas, a wall, and a room full of strangers becoming friends. Live music, free-flow art, and a takeaway piece you made yourself.",
                category: .creativeMystery,
                difficulty: .beginner,
                price: .budget,
                venueName: "The Warehouse Studio",
                generalArea: "Jersey City, NJ",
                latitude: 40.7178, longitude: -74.0431,
                eventTime: now.addingTimeInterval(7 * day + 20 * hour),
                revealTime: now.addingTimeInterval(7 * day),
                distanceMiles: 22,
                interests: [.arts, .music],
                clues: [
                    Clue(text: "Wear clothes you can mess up", symbol: "tshirt.fill", unlocksDaysBefore: 5),
                    Clue(text: "Indoor + creative", symbol: "paintpalette.fill", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 61, condition: "Cloudy", symbol: "cloud.fill"),
                imageSymbol: "paintbrush.pointed.fill"
            ),
            MysteryEvent(
                id: "e4",
                title: "Sunrise Cliff Hike + Coffee",
                eventDescription: "A guided dawn trek to a lookout most locals have never seen, capped with pour-over coffee at the summit. Small group, big views.",
                category: .outdoorChallenge,
                difficulty: .adventurous,
                price: .budget,
                venueName: "Palisades Ridge Trailhead",
                generalArea: "Bergen County, NJ",
                latitude: 40.9176, longitude: -73.9176,
                eventTime: now.addingTimeInterval(9 * day + 6 * hour),
                revealTime: now.addingTimeInterval(9 * day),
                distanceMiles: 30,
                interests: [.outdoor, .sports],
                clues: [
                    Clue(text: "Early start", symbol: "sunrise.fill", unlocksDaysBefore: 5),
                    Clue(text: "Bring good shoes", symbol: "figure.walk", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 52, condition: "Sunny", symbol: "sun.max.fill"),
                imageSymbol: "figure.hiking"
            ),
            MysteryEvent(
                id: "e5",
                title: "Rooftop Jazz & Tapas",
                eventDescription: "A live quartet, string lights, and small plates under the skyline. The kind of night that ends up as everyone's new favorite story.",
                category: .liveEntertainment,
                difficulty: .beginner,
                price: .premium,
                venueName: "The Skyline Terrace",
                generalArea: "New Brunswick, NJ",
                latitude: 40.4955, longitude: -74.4407,
                eventTime: now.addingTimeInterval(11 * day + 19 * hour),
                revealTime: now.addingTimeInterval(11 * day),
                distanceMiles: 6,
                interests: [.music, .food, .nightlife],
                clues: [
                    Clue(text: "Dress to impress", symbol: "sparkles", unlocksDaysBefore: 5),
                    Clue(text: "Great views", symbol: "building.2.fill", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 66, condition: "Warm evening", symbol: "moon.fill"),
                imageSymbol: "music.mic"
            ),
            MysteryEvent(
                id: "e6",
                title: "Retro Arcade Tournament",
                eventDescription: "Unlimited play, a bracket-style tournament, and pizza on the house. Winner takes the golden joystick (and bragging rights forever).",
                category: .socialMixer,
                difficulty: .medium,
                price: .moderate,
                venueName: "Pixel Palace Arcade",
                generalArea: "Edison, NJ",
                latitude: 40.5187, longitude: -74.4121,
                eventTime: now.addingTimeInterval(13 * day + 19 * hour),
                revealTime: now.addingTimeInterval(13 * day),
                distanceMiles: 11,
                interests: [.gaming, .food],
                clues: [
                    Clue(text: "Competitive spirit needed", symbol: "trophy.fill", unlocksDaysBefore: 5),
                    Clue(text: "Snacks included", symbol: "fork.knife", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 60, condition: "Clear", symbol: "moon.fill"),
                imageSymbol: "gamecontroller.fill"
            )
        ]
    }

    static func users() -> [AppUser] {
        [
            AppUser.demo,
            AppUser(id: "u2", name: "Sarah Chen", email: "sarah@ezrsvp.app",
                    username: "sarahc", bio: "Foodie. Will travel for ramen.",
                    city: "New Brunswick, NJ"),
            AppUser(id: "u3", name: "Jason Brooks", email: "jason@ezrsvp.app",
                    username: "jbrooks", bio: "Yes to live music, yes to everything.",
                    city: "Edison, NJ"),
            // Emily is a friend but keeps a private profile (viewable by friends, badged).
            AppUser(id: "u4", name: "Emily Patel", email: "emily@ezrsvp.app",
                    username: "empatel", bio: "Planner of the group chat.",
                    city: "Jersey City, NJ", isPrivate: true),
            AppUser(id: "u5", name: "Leo Martinez", email: "leo@ezrsvp.app",
                    username: "leom", bio: "Always looking for the next adventure.",
                    city: "New Brunswick, NJ"),
            // Sam is not a friend and is private → locked profile until added.
            AppUser(id: "u6", name: "Sam Okafor", email: "sam@ezrsvp.app",
                    username: "samok", bio: "Low-key legend.",
                    city: "Bergen, NJ", isPrivate: true)
        ]
    }

    /// Persistent crews (no longer tied to a single event).
    static func groups() -> [RSVPGroup] {
        let u = users()
        return [
            RSVPGroup(
                id: "g1", name: "Friday Adventure Squad", symbol: "moon.stars.fill",
                ownerID: "u1", inviteCode: "FRIDAY",
                members: [
                    GroupMember(user: u[0], status: .going, isReady: true),
                    GroupMember(user: u[1], status: .going, isReady: true),
                    GroupMember(user: u[2], status: .going, isReady: true),
                    GroupMember(user: u[3], status: .pending, isReady: false),
                    GroupMember(user: u[4], status: .maybe, isReady: false)
                ]
            ),
            RSVPGroup(
                id: "g2", name: "Rutgers Crew", symbol: "graduationcap.fill",
                ownerID: "u4", inviteCode: "RUKNGT",
                members: [
                    GroupMember(user: u[3], status: .going, isReady: true),
                    GroupMember(user: u[0], status: .going, isReady: true),
                    GroupMember(user: u[5], status: .going, isReady: false),
                    GroupMember(user: u[2], status: .maybe, isReady: false)
                ]
            ),
            RSVPGroup(
                id: "g3", name: "Random Friday Plans", symbol: "dice.fill",
                ownerID: "u5", inviteCode: "RANDOM",
                members: [
                    GroupMember(user: u[4], status: .going, isReady: true),
                    GroupMember(user: u[0], status: .going, isReady: false),
                    GroupMember(user: u[5], status: .going, isReady: true)
                ]
            )
        ]
    }

    /// The current user's friends (a subset — Leo & Sam are addable suggestions).
    static func friends() -> [AppUser] {
        let u = users()
        return [u[1], u[2], u[3]] // Sarah, Jason, Emily
    }

    /// Started RSVPs for the current user — one per crew so every crew (and the
    /// friends in it) has an upcoming mystery.
    static func quests() -> [Quest] {
        [
            Quest(id: "q1", eventID: "e1", crewID: "g1", ownerID: "u1"),
            Quest(id: "q2", eventID: "e2", crewID: "g2", ownerID: "u1"),
            Quest(id: "q3", eventID: "e6", crewID: "g3", ownerID: "u1")
        ]
    }

    /// Friends' activity for the FOMO feed.
    static func activity() -> [ActivityItem] {
        let u = users()
        return [
            ActivityItem(id: "a1", user: u[1], headline: "said yes to a mystery",
                         detail: "This Friday night · solo", symbol: "sparkles",
                         revealedEventID: nil, timeAgo: "2h"),
            ActivityItem(id: "a2", user: u[3], headline: "started a mystery with Rutgers Crew",
                         detail: "Reveals in 5 days", symbol: "person.2.fill",
                         revealedEventID: nil, timeAgo: "5h"),
            ActivityItem(id: "a3", user: u[2], headline: "discovered",
                         detail: "Rated it 🔥🔥🔥", symbol: "party.popper.fill",
                         revealedEventID: "e6", timeAgo: "Yesterday"),
            ActivityItem(id: "a4", user: u[1], headline: "said yes to a mystery",
                         detail: "Next weekend · with 3 friends", symbol: "sparkles",
                         revealedEventID: nil, timeAgo: "Yesterday"),
            ActivityItem(id: "a5", user: u[3], headline: "discovered",
                         detail: "Said it was unforgettable", symbol: "party.popper.fill",
                         revealedEventID: "e3", timeAgo: "2d")
        ]
    }
}
