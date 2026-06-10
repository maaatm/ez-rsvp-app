import Foundation

/// Runtime configuration. The app ships in **demo mode** (local mock backend),
/// so it builds and runs with zero setup — ideal for a live hackathon demo.
/// Flip `useSupabase` to true after adding the Supabase SPM package and filling
/// in `supabaseURL` / `supabaseAnonKey` (see README.md).
enum AppConfig {
    static let useSupabase = false

    /// Supabase project credentials (Project Settings → API). The anon key is a
    /// public client key — safe to ship; row-level security guards your data.
    static let supabaseURL = "https://YOUR-PROJECT.supabase.co"
    static let supabaseAnonKey = "YOUR-ANON-KEY"

    /// Artificial latency for the mock backend so skeleton loaders shine.
    static let mockLatency: Duration = .milliseconds(450)

    static let appName = "e-z.rsvp"
    static let tagline = "Say yes first. Find out later."
}
