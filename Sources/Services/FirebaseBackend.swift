import Foundation

// ============================================================================
// Production backend. Inert until the Firebase SPM packages are added — the
// whole implementation is gated on `canImport(FirebaseFirestore)` so the app
// compiles with zero external dependencies in demo mode.
//
// To enable:
//   1. Uncomment the Firebase packages/dependencies in project.yml
//   2. `xcodegen generate`
//   3. Add GoogleService-Info.plist to Resources/
//   4. Call FirebaseApp.configure() in EZRsvpApp.init()
//   5. Set AppConfig.useFirebase = true
// ============================================================================

#if canImport(FirebaseFirestore)
import FirebaseAuth
import FirebaseFirestore

actor FirebaseBackend: BackendService {
    private let db = Firestore.firestore()

    func signIn(with provider: AuthProvider, displayName: String?) async throws -> AppUser {
        // Wire up Sign in with Apple / Google OAuth credential → Auth.auth().signIn(...)
        // then upsert a profile document under /users/{uid}.
        switch provider {
        case .email(let email):
            // Example: passwordless or password sign-in.
            let result = try await Auth.auth().signIn(withEmail: email, password: "demo-password")
            return try await profile(for: result.user.uid, fallbackName: displayName, email: email)
        default:
            throw BackendError.notConfigured
        }
    }

    func signInWithApple(idTokenString: String, rawNonce: String, fullName: String?) async throws -> AppUser {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: nil
        )
        let result = try await Auth.auth().signIn(with: credential)
        return try await profile(
            for: result.user.uid,
            fallbackName: fullName ?? result.user.displayName,
            email: result.user.email ?? ""
        )
    }

    func signOut() async { try? Auth.auth().signOut() }

    func deleteAccount(userID: String) async throws {
        // Remove the profile document, then delete the auth user.
        try await db.collection("users").document(userID).delete()
        try await Auth.auth().currentUser?.delete()
    }

    private func profile(for uid: String, fallbackName: String?, email: String) async throws -> AppUser {
        let snap = try await db.collection("users").document(uid).getDocument()
        if let user = try? snap.data(as: AppUser.self) { return user }
        let new = AppUser(id: uid, name: fallbackName ?? "Guest", email: email)
        try db.collection("users").document(uid).setData(from: new)
        return new
    }

    func fetchEvents() async throws -> [MysteryEvent] {
        try await db.collection("events").getDocuments()
            .documents.compactMap { try? $0.data(as: MysteryEvent.self) }
    }

    func fetchGroups() async throws -> [RSVPGroup] {
        try await db.collection("groups").getDocuments()
            .documents.compactMap { try? $0.data(as: RSVPGroup.self) }
    }

    func createGroup(name: String, ownerID: String) async throws -> RSVPGroup {
        let group = RSVPGroup(name: name, ownerID: ownerID, inviteCode: generateInviteCode())
        try db.collection("groups").document(group.id).setData(from: group)
        return group
    }

    func joinGroup(code: String, user: AppUser) async throws -> RSVPGroup {
        let query = try await db.collection("groups")
            .whereField("inviteCode", isEqualTo: code).getDocuments()
        guard var group = try query.documents.first?.data(as: RSVPGroup.self) else {
            throw BackendError.groupNotFound
        }
        group.members.append(GroupMember(user: user, status: .going, isReady: false))
        try db.collection("groups").document(group.id).setData(from: group)
        return group
    }

    func setReady(groupID: String, userID: String, ready: Bool) async throws -> RSVPGroup {
        throw BackendError.notConfigured
    }
}
#endif
