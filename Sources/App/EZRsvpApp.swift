import SwiftUI
import TipKit

@main
struct EZRsvpApp: App {
    @State private var session = SessionStore()
    @State private var location = LocationService()

    init() {
        // The Supabase client initializes lazily inside SupabaseBackend from
        // AppConfig, so there's no global configure() to call here. See README.

        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(location)
                .preferredColorScheme(.light)
                .tint(Theme.ink)
        }
    }
}
