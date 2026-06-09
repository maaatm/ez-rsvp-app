import SwiftUI
import TipKit
#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct EZRsvpApp: App {
    @State private var session = SessionStore()
    @State private var location = LocationService()

    init() {
        // Enable in production once Firebase is added (see README).
        #if canImport(FirebaseCore)
        if AppConfig.useFirebase { FirebaseApp.configure() }
        #endif

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
