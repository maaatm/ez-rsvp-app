import SwiftUI

/// Top-level router: Onboarding (first launch) → Auth → Main app.
struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if !session.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if !session.isSignedIn {
                AuthView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.smooth(duration: 0.5), value: session.hasCompletedOnboarding)
        .animation(.smooth(duration: 0.5), value: session.isSignedIn)
        // Background fills to the screen edges (ignoresSafeArea) while the
        // foreground above keeps its safe-area insets — so buttons never slide
        // under the home indicator or screen edges.
        .background(GradientBackground())
        .task { await session.bootstrap() }
    }
}
