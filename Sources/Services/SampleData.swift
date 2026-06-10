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
            ),
            MysteryEvent(
                id: "e7",
                title: "Silent Forest Bathing + Sauna",
                eventDescription: "A guided morning of slow walking, deep breathing, and a wood-fired sauna deep in the trees. Phones stay in the basket. You leave lighter than you came.",
                category: .wellnessEscape,
                difficulty: .beginner,
                price: .premium,
                venueName: "Watchung Reservation Grove",
                generalArea: "Union County, NJ",
                latitude: 40.6895, longitude: -74.3779,
                eventTime: now.addingTimeInterval(3 * day + 9 * hour),
                revealTime: now.addingTimeInterval(3 * day),
                distanceMiles: 16,
                interests: [.outdoor],
                clues: [
                    Clue(text: "Leave the phone behind", symbol: "leaf.fill", unlocksDaysBefore: 5),
                    Clue(text: "Dress in warm layers", symbol: "tshirt.fill", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 55, condition: "Misty morning", symbol: "cloud.fog.fill"),
                imageSymbol: "leaf.fill"
            ),
            MysteryEvent(
                id: "e8",
                title: "Underground Comedy Cellar",
                eventDescription: "A no-name basement, a single mic, and a lineup you won't know until they're on stage. Some are touring headliners testing new material. All of it is off the record.",
                category: .liveEntertainment,
                difficulty: .beginner,
                price: .budget,
                venueName: "An Unmarked Basement Door",
                generalArea: "Hoboken, NJ",
                latitude: 40.7439, longitude: -74.0324,
                eventTime: now.addingTimeInterval(4 * day + 20 * hour),
                revealTime: now.addingTimeInterval(4 * day),
                distanceMiles: 20,
                interests: [.comedy, .nightlife],
                clues: [
                    Clue(text: "Bring your laugh", symbol: "theatermasks.fill", unlocksDaysBefore: 5),
                    Clue(text: "Two-drink minimum", symbol: "wineglass.fill", unlocksDaysBefore: 1)
                ],
                weather: Weather(temp: 59, condition: "Clear", symbol: "moon.fill"),
                imageSymbol: "theatermasks.fill"
            ),
            MysteryEvent(
                id: "e9",
                title: "Blindfolded Tasting Dinner",
                eventDescription: "Seven courses, no menu, and a blindfold for the first three. A chef's table experience built entirely around what you taste, not what you see.",
                category: .foodAdventure,
                difficulty: .medium,
                price: .premium,
                venueName: "An Undisclosed Chef's Table",
                generalArea: "Princeton, NJ",
                latitude: 40.3573, longitude: -74.6672,
                eventTime: now.addingTimeInterval(6 * day + 19 * hour),
                revealTime: now.addingTimeInterval(6 * day),
                distanceMiles: 18,
                interests: [.food],
                clues: [
                    Clue(text: "Trust your tastebuds", symbol: "fork.knife", unlocksDaysBefore: 5),
                    Clue(text: "Come with an open palate", symbol: "eye.slash.fill", unlocksDaysBefore: 2),
                    Clue(text: "Seven courses await", symbol: "list.number", unlocksDaysBefore: 1)
                ],
                weather: Weather(temp: 57, condition: "Cool", symbol: "cloud.fill"),
                imageSymbol: "fork.knife.circle.fill"
            ),
            MysteryEvent(
                id: "e10",
                title: "Mystery Trivia & Craft Beer",
                eventDescription: "A roving trivia night at a taproom that won't be named until the day. Categories are a secret, the beer is local, and the winning team drinks free.",
                category: .socialMixer,
                difficulty: .beginner,
                price: .moderate,
                venueName: "A Local Taproom",
                generalArea: "New Brunswick, NJ",
                latitude: 40.4860, longitude: -74.4510,
                eventTime: now.addingTimeInterval(8 * day + 19 * hour),
                revealTime: now.addingTimeInterval(8 * day),
                distanceMiles: 3,
                interests: [.food, .networking, .nightlife],
                clues: [
                    Clue(text: "Bring a teammate", symbol: "person.2.fill", unlocksDaysBefore: 5),
                    Clue(text: "Know a little of everything", symbol: "brain.head.profile", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 62, condition: "Mild", symbol: "moon.fill"),
                imageSymbol: "questionmark.bubble.fill"
            ),
            MysteryEvent(
                id: "e11",
                title: "Kayak Sunset Paddle",
                eventDescription: "A small-group launch onto calm water just as the sun drops. Glide past the skyline, raft up midstream for a toast, and paddle back under the first stars.",
                category: .outdoorChallenge,
                difficulty: .medium,
                price: .moderate,
                venueName: "A Quiet Riverbend",
                generalArea: "Raritan River, NJ",
                latitude: 40.5276, longitude: -74.5890,
                eventTime: now.addingTimeInterval(10 * day + 7 * hour),
                revealTime: now.addingTimeInterval(10 * day),
                distanceMiles: 14,
                interests: [.outdoor, .sports],
                clues: [
                    Clue(text: "You'll get a little wet", symbol: "drop.fill", unlocksDaysBefore: 5),
                    Clue(text: "Golden-hour launch", symbol: "sunset.fill", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 68, condition: "Calm waters", symbol: "sun.max.fill"),
                imageSymbol: "sailboat.fill"
            ),
            MysteryEvent(
                id: "e12",
                title: "Pottery Wheel & Wine",
                eventDescription: "A hands-on evening at a hidden ceramics loft. Throw your first bowl, get gloriously messy, and sip a glass while the wheel spins. Your piece ships to you once it's fired.",
                category: .creativeMystery,
                difficulty: .beginner,
                price: .moderate,
                venueName: "A Hidden Ceramics Loft",
                generalArea: "Montclair, NJ",
                latitude: 40.8259, longitude: -74.2090,
                eventTime: now.addingTimeInterval(12 * day + 19 * hour),
                revealTime: now.addingTimeInterval(12 * day),
                distanceMiles: 24,
                interests: [.arts],
                clues: [
                    Clue(text: "Hands will get messy", symbol: "hands.sparkles.fill", unlocksDaysBefore: 5),
                    Clue(text: "A glass is on us", symbol: "wineglass.fill", unlocksDaysBefore: 2)
                ],
                weather: Weather(temp: 60, condition: "Cozy indoors", symbol: "cloud.fill"),
                imageSymbol: "paintbrush.fill"
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

    /// A small demo friend graph (userID → friend userIDs) so every profile can
    /// show who *they* are friends with, not just the current user. The current
    /// user's own friends come from the live `SessionStore.friends` list instead,
    /// so anyone they add shows up immediately.
    static func friendIDs(forUser userID: String) -> [String] {
        let graph: [String: [String]] = [
            "u1": ["u2", "u3", "u4"],       // You — fallback; live list used at runtime
            "u2": ["u1", "u3", "u4", "u5"], // Sarah
            "u3": ["u1", "u2", "u5", "u6"], // Jason
            "u4": ["u1", "u2", "u6"],       // Emily
            "u5": ["u2", "u3", "u6"],       // Leo
            "u6": ["u3", "u4", "u5"]        // Sam
        ]
        return graph[userID] ?? []
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
