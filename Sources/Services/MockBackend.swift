import Foundation

/// In-memory backend for demo mode. An `actor` for safe concurrent access and
/// free `Sendable` conformance. Seeded from `SampleData`.
actor MockBackend: BackendService {
    private var events: [MysteryEvent]
    private var groups: [RSVPGroup]

    init() {
        events = SampleData.events()
        groups = SampleData.groups()
    }

    private func simulateLatency() async {
        try? await Task.sleep(for: AppConfig.mockLatency)
    }

    // MARK: Auth

    func signIn(with provider: AuthProvider, displayName: String?) async throws -> AppUser {
        await simulateLatency()
        switch provider {
        case .apple:
            return AppUser(id: "u1", name: displayName ?? "Apple User", email: "apple@ezrsvp.app")
        case .google:
            return AppUser(id: "u1", name: displayName ?? "Alex Rivera", email: "alex@gmail.com")
        case .email(let email):
            let name = displayName ?? email.split(separator: "@").first.map(String.init)?.capitalized ?? "Guest"
            return AppUser(id: "u1", name: name, email: email)
        }
    }

    func signInWithApple(idTokenString: String, rawNonce: String, fullName: String?) async throws -> AppUser {
        await simulateLatency()
        return AppUser(id: "u1", name: fullName ?? "Apple User", email: "apple@ezrsvp.app")
    }

    func signOut() async {}

    func deleteAccount(userID: String) async throws {
        // Demo: nothing server-side to delete; local state is cleared by SessionStore.
    }

    // MARK: Data

    func fetchEvents() async throws -> [MysteryEvent] {
        await simulateLatency()
        return events
    }

    func fetchGroups() async throws -> [RSVPGroup] {
        await simulateLatency()
        return groups
    }

    // MARK: Mutations

    func createGroup(name: String, ownerID: String) async throws -> RSVPGroup {
        let owner = SampleData.users().first { $0.id == ownerID } ?? AppUser.demo
        let group = RSVPGroup(
            name: name,
            symbol: "sparkles",
            ownerID: ownerID,
            inviteCode: generateInviteCode(),
            members: [GroupMember(user: owner, status: .going, isReady: true)]
        )
        groups.insert(group, at: 0)
        return group
    }

    func joinGroup(code: String, user: AppUser) async throws -> RSVPGroup {
        await simulateLatency()
        guard let idx = groups.firstIndex(where: { $0.inviteCode.caseInsensitiveCompare(code) == .orderedSame }) else {
            throw BackendError.groupNotFound
        }
        if !groups[idx].members.contains(where: { $0.user.id == user.id }) {
            groups[idx].members.append(GroupMember(user: user, status: .going, isReady: false))
        }
        return groups[idx]
    }

    func setReady(groupID: String, userID: String, ready: Bool) async throws -> RSVPGroup {
        guard let gIdx = groups.firstIndex(where: { $0.id == groupID }),
              let mIdx = groups[gIdx].members.firstIndex(where: { $0.user.id == userID })
        else { throw BackendError.groupNotFound }
        groups[gIdx].members[mIdx].isReady = ready
        return groups[gIdx]
    }
}
