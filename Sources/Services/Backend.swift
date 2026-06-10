import Foundation

enum AuthProvider {
    case apple, google, email(String)
}

/// Abstraction over the data/auth layer. `MockBackend` powers demo mode;
/// `SupabaseBackend` is a drop-in for production. Inject either through
/// `SessionStore` — nothing else in the app knows which is live.
protocol BackendService: Sendable {
    // Auth
    func signIn(with provider: AuthProvider, displayName: String?) async throws -> AppUser
    /// Real Sign in with Apple — exchanges the Apple identity token (+ nonce) for
    /// a session. In demo mode this returns a local user.
    func signInWithApple(idTokenString: String, rawNonce: String, fullName: String?) async throws -> AppUser
    func signOut() async
    /// Permanently deletes the account + associated data (App Store requirement).
    func deleteAccount(userID: String) async throws

    // Data
    func fetchEvents() async throws -> [MysteryEvent]
    func fetchGroups() async throws -> [RSVPGroup]

    // Mutations
    func createGroup(name: String, ownerID: String) async throws -> RSVPGroup
    func joinGroup(code: String, user: AppUser) async throws -> RSVPGroup
    func setReady(groupID: String, userID: String, ready: Bool) async throws -> RSVPGroup
}

enum BackendError: LocalizedError {
    case groupNotFound
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .groupNotFound: return "We couldn't find a group with that invite code."
        case .notConfigured: return "Backend is not configured. Running in demo mode."
        }
    }
}
