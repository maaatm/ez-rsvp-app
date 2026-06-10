import Foundation
import Observation

/// Root app state + lightweight DI container. Owns the active backend and the
/// signed-in user, and exposes high-level intents to the feature view-models.
@MainActor
@Observable
final class SessionStore {
    // Auth / onboarding
    var currentUser: AppUser?
    var hasCompletedOnboarding: Bool

    // Cached data
    var events: [MysteryEvent] = []
    var groups: [RSVPGroup] = []   // crews
    var quests: [Quest] = []       // started RSVPs
    var friends: [AppUser] = []
    var activity: [ActivityItem] = []
    var isLoading = false

    let backend: BackendService

    private let defaults = UserDefaults.standard
    private let userKey = "ezrsvp.currentUser"
    private let onboardingKey = "ezrsvp.onboarded"
    private let pendingKey = "ezrsvp.pendingProfile"

    /// Onboarding choices captured before sign-in, applied to the user on auth.
    private struct PendingProfile: Codable {
        var interests: [Interest]
        var budget: PriceTier
        var radius: Double
        var availability: [String]
    }

    init(backend: BackendService? = nil) {
        if let backend {
            self.backend = backend
        } else if AppConfig.useSupabase {
            #if canImport(Supabase)
            self.backend = SupabaseBackend()
            #else
            self.backend = MockBackend()
            #endif
        } else {
            self.backend = MockBackend()
        }

        hasCompletedOnboarding = defaults.bool(forKey: onboardingKey)
        if let data = defaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(AppUser.self, from: data) {
            currentUser = user
        }
    }

    var isSignedIn: Bool { currentUser != nil }

    // MARK: Lifecycle

    func bootstrap() async {
        guard isSignedIn else { return }
        // Instant cold-start render from the SwiftData cache.
        if events.isEmpty {
            let cached = EventCache.shared.load()
            if !cached.isEmpty { events = cached }
        }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        async let e = try? await backend.fetchEvents()
        async let g = try? await backend.fetchGroups()
        let fetchedEvents = await e ?? []
        events = fetchedEvents
        groups = await g ?? []
        if !fetchedEvents.isEmpty {
            EventCache.shared.save(fetchedEvents)
        }
        // Quests / friends / activity are demo-seeded client-side (production
        // would fetch these from the backend). Seed once so user-created quests
        // and added friends persist across refreshes.
        if quests.isEmpty { quests = SampleData.quests() }
        if friends.isEmpty { friends = SampleData.friends() }
        if activity.isEmpty { activity = SampleData.activity() }
    }

    // MARK: Auth

    func signIn(with provider: AuthProvider, displayName: String? = nil) async throws {
        var user = try await backend.signIn(with: provider, displayName: displayName)
        // Apply any onboarding choices captured before sign-in.
        if let data = defaults.data(forKey: pendingKey),
           let pending = try? JSONDecoder().decode(PendingProfile.self, from: data) {
            user.interests = pending.interests
            user.budget = pending.budget
            user.radiusMiles = pending.radius
            user.availability = pending.availability
        }
        persist(user)
        await refresh()
    }

    /// Called from onboarding (which runs BEFORE auth). Stashes preferences
    /// until the user signs in, without creating a session.
    func completeOnboarding(interests: [Interest], budget: PriceTier, radius: Double, availability: [String]) {
        let pending = PendingProfile(interests: interests, budget: budget, radius: radius, availability: availability)
        if let data = try? JSONEncoder().encode(pending) {
            defaults.set(data, forKey: pendingKey)
        }
        hasCompletedOnboarding = true
        defaults.set(true, forKey: onboardingKey)
        // If already signed in (re-running onboarding), apply immediately.
        if var user = currentUser {
            user.interests = interests
            user.budget = budget
            user.radiusMiles = radius
            user.availability = availability
            persist(user)
        }
    }

    func signInWithApple(idTokenString: String, rawNonce: String, fullName: String?) async throws {
        var user = try await backend.signInWithApple(
            idTokenString: idTokenString, rawNonce: rawNonce, fullName: fullName
        )
        if let data = defaults.data(forKey: pendingKey),
           let pending = try? JSONDecoder().decode(PendingProfile.self, from: data) {
            user.interests = pending.interests
            user.budget = pending.budget
            user.radiusMiles = pending.radius
            user.availability = pending.availability
        }
        persist(user)
        await refresh()
    }

    /// Permanently deletes the account and resets to a clean first-run state.
    func deleteAccount() async {
        if let uid = currentUser?.id {
            try? await backend.deleteAccount(userID: uid)
        }
        currentUser = nil
        groups = []
        quests = []
        friends = []
        activity = []
        hasCompletedOnboarding = false
        defaults.removeObject(forKey: userKey)
        defaults.removeObject(forKey: onboardingKey)
        defaults.removeObject(forKey: pendingKey)
    }

    func setPreferredMaps(_ app: MapsApp) {
        guard var user = currentUser else { return }
        user.preferredMaps = app
        persist(user)
    }

    // MARK: Profile editing

    /// Updates the editable identity fields. Empty name/username are ignored /
    /// cleared rather than persisting blanks.
    func updateProfile(name: String, username: String, bio: String) {
        guard var user = currentUser else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty { user.name = trimmedName }
        user.username = AppUser.sanitizeUsername(username)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        user.bio = trimmedBio.isEmpty ? nil : trimmedBio
        persist(user)
    }

    /// Persists a freshly picked profile photo to Documents and points the user
    /// at it. A unique filename per pick sidesteps AsyncImage's URL cache, and the
    /// previous local avatar is cleaned up.
    func setProfilePhoto(_ data: Data) {
        guard var user = currentUser else { return }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = dir.appendingPathComponent("avatar-\(user.id)-\(Int(Date().timeIntervalSince1970)).jpg")
        do {
            try data.write(to: url, options: .atomic)
            // Clean up the previous avatar. Resolve it by filename against the
            // current Documents dir, since a stored absolute path may be stale
            // after a container change.
            if let old = user.photoURL, old.isFileURL {
                let oldResolved = dir.appendingPathComponent(old.lastPathComponent)
                try? FileManager.default.removeItem(at: oldResolved)
            }
            user.photoURL = url
            persist(user)
        } catch {
            // Non-fatal: keep the existing avatar if the write fails.
        }
    }

    func signOut() {
        Task { await backend.signOut() }
        currentUser = nil
        defaults.removeObject(forKey: userKey)
    }

    private func persist(_ user: AppUser) {
        currentUser = user
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: userKey)
        }
    }

    // MARK: Convenience lookups

    func event(id: String) -> MysteryEvent? { events.first { $0.id == id } }

    func group(id: String) -> RSVPGroup? { groups.first { $0.id == id } }

    // MARK: Reveals

    /// Events whose mystery has been opened this session — even if their real
    /// `revealTime` is still in the future (e.g. the demo trigger). Keeps a
    /// reveal permanent as the user navigates away and back.
    var revealedEventIDs: Set<String> = []

    /// True once the mystery is open — by the clock, or because it was revealed
    /// manually. Prefer this over `MysteryEvent.isRevealed()` in the UI.
    func isRevealed(_ event: MysteryEvent) -> Bool {
        event.isRevealed() || revealedEventIDs.contains(event.id)
    }

    /// Marks an event permanently revealed for the rest of the session.
    func reveal(_ eventID: String) {
        revealedEventIDs.insert(eventID)
    }

    // MARK: Payments

    /// Events the current user has paid their ticket for. A crew can assign an
    /// event for free; each member then pays their own ticket from the reveal
    /// room. Solo plans are paid up front. In-memory, like reveals.
    var paidEventIDs: Set<String> = []

    func hasPaid(_ eventID: String) -> Bool { paidEventIDs.contains(eventID) }

    func markPaid(_ eventID: String) { paidEventIDs.insert(eventID) }

    // MARK: Quests

    func quest(forEvent eventID: String) -> Quest? { quests.first { $0.eventID == eventID } }

    /// The active quest a crew has started (if any).
    func activeQuest(forCrew crewID: String) -> Quest? { quests.first { $0.crewID == crewID } }

    /// The crew attending the quest for a given event (nil = solo / none).
    func crew(forEvent eventID: String) -> RSVPGroup? {
        guard let crewID = quest(forEvent: eventID)?.crewID else { return nil }
        return group(id: crewID)
    }

    /// The soonest-revealing quest — the dashboard headliner.
    var headlineQuest: Quest? {
        quests
            .compactMap { q -> (Quest, Date)? in
                guard let e = event(id: q.eventID) else { return nil }
                return (q, e.revealTime)
            }
            .min { $0.1 < $1.1 }?.0
    }

    var headlineEvent: MysteryEvent? { headlineQuest.flatMap { event(id: $0.eventID) } }

    /// Every event the user has said yes to (started a quest on), soonest
    /// reveal first. The first element is the `headlineEvent`; the rest fill the
    /// "other RSVPs" list on Home.
    var signedUpEvents: [MysteryEvent] {
        quests
            .compactMap { event(id: $0.eventID) }
            .sorted { $0.revealTime < $1.revealTime }
    }

    var recommendations: [ScoredEvent] {
        guard let user = currentUser else { return [] }
        return RecommendationEngine.recommend(events, for: RecommendationProfile(user: user), explore: true)
    }

    /// Events the user hasn't already started a quest for.
    var unclaimedEvents: [MysteryEvent] {
        let taken = Set(quests.map(\.eventID))
        return events.filter { !taken.contains($0.id) }
    }

    // MARK: Matching

    private func priceLevel(_ p: PriceTier) -> Int {
        [PriceTier.budget: 0, .moderate: 1, .premium: 2][p] ?? 1
    }

    /// Finds the best-fitting mystery for a set of guardrail preferences,
    /// applying dealbreakers as hard filters and the recommendation engine for
    /// ranking. The chosen event stays hidden — only its *fit* is used.
    func matchEvent(preferences prefs: RSVPPreferences, excluding: Set<String> = []) -> MysteryEvent? {
        let candidates = events.filter { e in
            if excluding.contains(e.id) { return false }
            if priceLevel(e.price) > priceLevel(prefs.priceCeiling) { return false }
            if e.distanceMiles > prefs.maxDistance { return false }
            for db in prefs.dealbreakers {
                switch db {
                case .indoorOnly:
                    if e.category == .outdoorChallenge || e.interests.contains(.outdoor) { return false }
                case .keepClose:
                    if e.distanceMiles > 12 { return false }
                case .lowKey:
                    if e.difficulty == .adventurous { return false }
                case .noLateNight:
                    if e.interests.contains(.nightlife) { return false }
                case .noLoud:
                    if e.category == .liveEntertainment { return false }
                }
            }
            return true
        }
        let profile = RecommendationProfile(
            interests: currentUser?.interests ?? [],
            maxDistance: prefs.maxDistance,
            pricePreference: Double(priceLevel(prefs.priceCeiling)) / 2.0,
            adventurousness: prefs.adventurousness
        )
        return RecommendationEngine.recommend(candidates, for: profile, explore: true).first?.event
    }

    // MARK: Quest mutations

    /// Starts a matched mystery RSVP for a crew (or solo). Returns the new quest.
    @discardableResult
    func startQuest(crewID: String?, preferences: RSVPPreferences) -> Quest? {
        guard let uid = currentUser?.id else { return nil }
        let taken = Set(quests.map(\.eventID))
        guard let event = matchEvent(preferences: preferences, excluding: taken)
                ?? matchEvent(preferences: preferences) else { return nil }
        let quest = Quest(eventID: event.id, crewID: crewID, ownerID: uid, preferences: preferences)
        quests.insert(quest, at: 0)
        return quest
    }

    /// Commits to a specific (still-hidden) matched event — used by Discover's
    /// "say yes." No-ops to the existing quest if already claimed.
    @discardableResult
    func sayYes(to eventID: String, crewID: String? = nil) -> Quest? {
        guard let uid = currentUser?.id else { return nil }
        if let existing = quests.first(where: { $0.eventID == eventID }) { return existing }
        let quest = Quest(eventID: eventID, crewID: crewID, ownerID: uid)
        quests.insert(quest, at: 0)
        return quest
    }

    // MARK: Crew mutations

    @discardableResult
    func createGroup(name: String) async -> RSVPGroup? {
        guard let uid = currentUser?.id else { return nil }
        if let group = try? await backend.createGroup(name: name, ownerID: uid) {
            groups.insert(group, at: 0)
            return group
        }
        return nil
    }

    func joinGroup(code: String) async throws {
        guard let user = currentUser else { return }
        let group = try await backend.joinGroup(code: code, user: user)
        upsert(group)
    }

    func setReady(groupID: String, ready: Bool) async {
        guard let uid = currentUser?.id else { return }
        if let group = try? await backend.setReady(groupID: groupID, userID: uid, ready: ready) {
            upsert(group)
        }
    }

    private func upsert(_ group: RSVPGroup) {
        if let idx = groups.firstIndex(where: { $0.id == group.id }) {
            groups[idx] = group
        } else {
            groups.insert(group, at: 0)
        }
    }

    // MARK: Friends

    var suggestedFriends: [AppUser] {
        SampleData.users().filter { u in
            u.id != currentUser?.id && !friends.contains { $0.id == u.id }
        }
    }

    func addFriend(_ user: AppUser) {
        guard !friends.contains(where: { $0.id == user.id }) else { return }
        friends.insert(user, at: 0)
        activity.insert(
            ActivityItem(id: UUID().uuidString, user: user,
                         headline: "is now your friend", detail: "Say yes to a mystery together",
                         symbol: "person.fill.badge.plus", revealedEventID: nil, timeAgo: "now"),
            at: 0
        )
    }

    func isFriend(_ user: AppUser) -> Bool {
        friends.contains { $0.id == user.id }
    }

    /// Privacy gate: you can always see yourself and public profiles; private
    /// profiles are only visible to friends.
    func canViewProfile(of user: AppUser) -> Bool {
        if user.id == currentUser?.id { return true }
        if !user.isPrivateProfile { return true }
        return isFriend(user)
    }

    func setPrivate(_ isPrivate: Bool) {
        guard var user = currentUser else { return }
        user.isPrivate = isPrivate
        persist(user)
    }

    // MARK: Other people's profiles

    /// A given user's friends. For the current user this is the live, mutable
    /// friends list (so anyone they just added appears right away); for everyone
    /// else it's resolved from the demo friend graph.
    func friends(forUser userID: String) -> [AppUser] {
        if userID == currentUser?.id { return friends }
        let all = SampleData.users()
        return SampleData.friendIDs(forUser: userID).compactMap { id in
            all.first { $0.id == id }
        }
    }

    /// Crews a given user belongs to (that the current user can see).
    func crews(forUser userID: String) -> [RSVPGroup] {
        groups.filter { crew in crew.members.contains { $0.user.id == userID } }
    }

    /// A user's upcoming mysteries — surfaced as mysteries (event + crew), never
    /// spoiling the venue. Derived from active quests of crews they're in.
    func upcomingMysteries(forUser userID: String) -> [(event: MysteryEvent, crew: RSVPGroup)] {
        var seen = Set<String>()
        var result: [(MysteryEvent, RSVPGroup)] = []
        for crew in crews(forUser: userID) {
            guard let quest = activeQuest(forCrew: crew.id),
                  let event = event(id: quest.eventID),
                  !seen.contains(event.id) else { continue }
            seen.insert(event.id)
            result.append((event, crew))
        }
        return result.sorted { $0.0.revealTime < $1.0.revealTime }
    }
}
