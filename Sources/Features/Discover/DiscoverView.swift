import SwiftUI

/// Discover is the **matching surface**, not a catalog. You're offered one
/// mystery at a time (matched to you) and you say yes or pass — the whole point
/// is the system picks, not you. Below sits the social feed (FOMO).
struct DiscoverView: View {
    @Environment(SessionStore.self) private var session
    @State private var skipped: Set<String> = []
    @State private var confirmation: String?
    @State private var showRefine = false

    private var offers: [ScoredEvent] {
        let taken = Set(session.quests.map(\.eventID)).union(skipped)
        let profile = session.currentUser.map { RecommendationProfile(user: $0) }
            ?? RecommendationProfile(interests: [])
        return RecommendationEngine.recommend(
            session.events.filter { !taken.contains($0.id) }, for: profile
        )
    }
    private var currentOffer: ScoredEvent? { offers.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    Text("One mystery at a time, matched to you. Say yes — or pass to see another.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    if let banner = confirmation { confirmationBanner(banner) }

                    if session.events.isEmpty {
                        RoundedRectangle(cornerRadius: Theme.Radius.lg).fill(Theme.surfaceSunken)
                            .frame(height: 320).redacted(reason: .placeholder).shimmering()
                    } else if let offer = currentOffer {
                        offerCard(offer)
                    } else {
                        allClaimed
                    }

                    friendsFeed
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Discover")
            .sheet(isPresented: $showRefine) {
                QuestPreferencesSheet(crewID: nil) { _ in confirm("🎟️ You're in! Find it on Home.") }
            }
        }
    }

    // MARK: Offer

    private func offerCard(_ offer: ScoredEvent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "A mystery matched for you",
                          subtitle: "You only see the vibe — the rest reveals on the day")

            EventCard(event: offer.event, matchScore: offer.score, topReason: offer.reasons.first)

            HStack(spacing: 12) {
                Button {
                    Haptics.selection()
                    withAnimation { _ = skipped.insert(offer.event.id) }
                } label: {
                    Label("Pass", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.secondary)

                Button {
                    Haptics.notify(.success)
                    session.sayYes(to: offer.event.id)
                    confirm("🎟️ You said yes! Find it on Home.")
                } label: {
                    Label("Say yes", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.primary)
            }

            Button { showRefine = true } label: {
                Label("Refine what you'd hate", systemImage: "slider.horizontal.3")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.violet)
            .frame(maxWidth: .infinity)
        }
    }

    private var allClaimed: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(Theme.brandGradient)
            Text("You've said yes to everything available").font(.headline)
            Text("Nice. Check back soon for fresh mysteries — or start one with a crew in Social.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.xl)
        .glass(cornerRadius: Theme.Radius.lg)
    }

    private func confirmationBanner(_ text: String) -> some View {
        Label(text, systemImage: "sparkles")
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .glass(cornerRadius: Theme.Radius.md)
            .gradientBorder(cornerRadius: Theme.Radius.md, lineWidth: 1)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: Friends feed

    private var friendsFeed: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your friends are saying yes",
                          subtitle: "Don't be the one who missed it")
            ForEach(session.activity.prefix(6)) { item in
                NavigationLink {
                    FriendProfileView(user: item.user)
                } label: {
                    ActivityRow(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func confirm(_ message: String) {
        withAnimation { confirmation = message }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation { confirmation = nil }
        }
    }
}
