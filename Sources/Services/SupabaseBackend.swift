import Foundation

// ============================================================================
// Production backend. Inert until the Supabase SPM package is added — the whole
// implementation is gated on `canImport(Supabase)` so the app compiles with zero
// external dependencies in demo mode.
//
// To enable:
//   1. Uncomment the Supabase package/dependency in project.yml
//   2. `xcodegen generate`
//   3. Set AppConfig.supabaseURL + AppConfig.supabaseAnonKey (your project's
//      values from Supabase → Project Settings → API)
//   4. Set AppConfig.useSupabase = true
//   5. In Supabase → Authentication → Providers, enable Apple (and Google), and
//      create the `profiles`, `events`, `groups` tables (see supabase-schema.md)
// ============================================================================

#if canImport(Supabase)
import Supabase

actor SupabaseBackend: BackendService {
    private let client = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseAnonKey
    )

    func signIn(with provider: AuthProvider, displayName: String?) async throws -> AppUser {
        // Wire up an OAuth credential → client.auth, then upsert a row in
        // `profiles` keyed on the auth user's id.
        switch provider {
        case .email(let email):
            // Example: password sign-in. Supabase also offers passwordless OTP /
            // magic links via `signInWithOTP(email:)`.
            let session = try await client.auth.signIn(email: email, password: "demo-password")
            return try await profile(for: session.user.id, fallbackName: displayName, email: email)
        default:
            throw BackendError.notConfigured
        }
    }

    func signInWithApple(idTokenString: String, rawNonce: String, fullName: String?) async throws -> AppUser {
        let session = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idTokenString,
                nonce: rawNonce
            )
        )
        return try await profile(
            for: session.user.id,
            fallbackName: fullName,
            email: session.user.email ?? ""
        )
    }

    func signOut() async { try? await client.auth.signOut() }

    func deleteAccount(userID: String) async throws {
        // Remove the profile row, then delete the auth user. Supabase blocks
        // client-side user deletion with the anon key, so the actual auth-user
        // delete runs in a SECURITY DEFINER Postgres function exposed via RPC.
        try await client.from("profiles").delete().eq("id", value: userID).execute()
        try await client.rpc("delete_account").execute()
    }

    private func profile(for uid: UUID, fallbackName: String?, email: String) async throws -> AppUser {
        let id = uid.uuidString
        let existing: AppUser? = try await client
            .from("profiles")
            .select()
            .eq("id", value: id)
            .maybeSingle()
            .execute()
            .value
        if let existing { return existing }

        let new = AppUser(id: id, name: fallbackName ?? "Guest", email: email)
        try await client.from("profiles").insert(new).execute()
        return new
    }

    func fetchEvents() async throws -> [MysteryEvent] {
        try await client.from("events").select().execute().value
    }

    func fetchGroups() async throws -> [RSVPGroup] {
        try await client.from("groups").select().execute().value
    }

    func createGroup(name: String, ownerID: String) async throws -> RSVPGroup {
        let group = RSVPGroup(name: name, ownerID: ownerID, inviteCode: generateInviteCode())
        try await client.from("groups").insert(group).execute()
        return group
    }

    func joinGroup(code: String, user: AppUser) async throws -> RSVPGroup {
        let match: RSVPGroup? = try await client
            .from("groups")
            .select()
            .eq("inviteCode", value: code)
            .maybeSingle()
            .execute()
            .value
        guard var group = match else { throw BackendError.groupNotFound }
        group.members.append(GroupMember(user: user, status: .going, isReady: false))
        try await client.from("groups").update(group).eq("id", value: group.id).execute()
        return group
    }

    func setReady(groupID: String, userID: String, ready: Bool) async throws -> RSVPGroup {
        throw BackendError.notConfigured
    }
}
#endif
