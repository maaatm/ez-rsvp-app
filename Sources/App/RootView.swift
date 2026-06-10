import SwiftUI

/// Top-level router: Onboarding (first launch) → Auth → Main app.
struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if !session.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                    .background(GradientBackground())
            } else if !session.isSignedIn {
                // The sign-up / sign-in screen sits on a plain background —
                // no aurora gradient behind it.
                AuthView()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .background(Theme.background.ignoresSafeArea())
            } else {
                MainTabView()
                    .transition(.opacity)
                    .background(GradientBackground())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.smooth(duration: 0.5), value: session.hasCompletedOnboarding)
        .animation(.smooth(duration: 0.5), value: session.isSignedIn)
        // The gradient backdrop (where used) fills to the screen edges
        // (ignoresSafeArea) while the foreground keeps its safe-area insets —
        // so buttons never slide under the home indicator or screen edges.
        .task { await session.bootstrap() }
    }
}
