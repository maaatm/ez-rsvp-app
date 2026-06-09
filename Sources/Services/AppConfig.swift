import Foundation

/// Runtime configuration. The app ships in **demo mode** (local mock backend),
/// so it builds and runs with zero setup — ideal for a live hackathon demo.
/// Flip `useFirebase` to true after adding the Firebase SPM packages and
/// GoogleService-Info.plist (see README.md).
enum AppConfig {
    static let useFirebase = false

    /// Artificial latency for the mock backend so skeleton loaders shine.
    static let mockLatency: Duration = .milliseconds(450)

    static let appName = "e-z.rsvp"
    static let tagline = "Say yes first. Find out later."
}
