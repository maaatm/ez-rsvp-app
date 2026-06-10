import SwiftUI

/// Discover is a **browsable mystery list**. The web app's "Find events" filters
/// (location, radius, max price, sort, categories, mystery mode) narrow the field,
/// and the recommendation engine ranks what's left. You scroll the matches, tap
/// one for the vibe, and add it to a solo or crew RSVP — the event itself stays a
/// mystery until reveal day.
struct DiscoverView: View {
    @Environment(SessionStore.self) private var session
    @State private var showFilters = false
    @State private var filters = DiscoverFilters()

    private var profile: RecommendationProfile {
        session.currentUser.map { RecommendationProfile(user: $0) }
            ?? RecommendationProfile(interests: [])
    }

    /// Events matching the active filters, ranked — excluding any the user has
    /// already said yes to. Those live on Home and the crew's page now, so
    /// Discover only shows mysteries still open to you.
    private var offers: [ScoredEvent] {
        let claimed = Set(session.quests.map(\.eventID))
        let open = session.events.filter { !claimed.contains($0.id) }
        return filters.rank(open, for: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    Text("Browse mysteries matched to you. Tap one for the vibe, then add it solo or bring a crew.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    filterBar

                    if session.events.isEmpty {
                        RoundedRectangle(cornerRadius: Theme.Radius.lg).fill(Theme.surfaceSunken)
                            .frame(height: 320).redacted(reason: .placeholder).shimmering()
                    } else if offers.isEmpty {
                        noMatches
                    } else {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: countTitle,
                                          subtitle: "Tap one for the vibe — then add it solo or with a crew")
                            ForEach(offers) { offer in
                                listRow(offer)
                            }
                        }
                    }
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showFilters = true } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("Filters")
                }
            }
            .sheet(isPresented: $showFilters) {
                DiscoverFiltersSheet(filters: $filters)
            }
        }
    }

    private var countTitle: String {
        "\(offers.count) \(offers.count == 1 ? "mystery" : "mysteries") match"
    }

    // MARK: List

    private func listRow(_ offer: ScoredEvent) -> some View {
        NavigationLink {
            MysteryDetailView(event: offer.event, score: offer.score,
                              reasons: offer.reasons, hideCategory: filters.mysteryMode)
        } label: {
            EventCard(event: offer.event,
                      matchScore: offer.score,
                      topReason: offer.reasons.first,
                      hideCategory: filters.mysteryMode)
        }
        .buttonStyle(.plain)
    }

    // MARK: Filter summary bar

    private var filterBar: some View {
        Button { showFilters = true } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Filters", systemImage: "slider.horizontal.3")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
                    Spacer()
                    Text("Edit").font(.caption.weight(.semibold))
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(Theme.violet)

                FlowLayout(spacing: 8) {
                    filterPill("mappin.and.ellipse", filters.selectedLocation?.label ?? "Anywhere")
                    if filters.selectedLocation != nil {
                        filterPill("location.circle", "\(Int(filters.radius)) mi")
                    }
                    filterPill("dollarsign.circle", "≤ $\(Int(filters.maxPrice))")
                    filterPill("arrow.up.arrow.down", filters.sort.short)
                    filterPill(filters.mysteryMode ? "eye.slash" : "square.grid.2x2",
                               filters.mysteryMode ? "Mystery" : "Categories")
                }
            }
            .padding(14)
            .glass(cornerRadius: Theme.Radius.md)
        }
        .buttonStyle(.plain)
    }

    private func filterPill(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol).font(.caption2)
            Text(text).font(.caption.weight(.medium)).lineLimit(1)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .foregroundStyle(Theme.ink)
        .background(Theme.surfaceSunken, in: Capsule())
    }

    private var noMatches: some View {
        VStack(spacing: 10) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.largeTitle).foregroundStyle(Theme.violet)
            Text("No mysteries match those filters").font(.headline)
            Text("Try increasing your radius, raising your max price, or choosing a nearby address.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Adjust filters") { showFilters = true }
                .buttonStyle(.secondary(fullWidth: false))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.xl)
        .glass(cornerRadius: Theme.Radius.lg)
    }
}

// MARK: - Mystery detail

/// The tap-through detail for a single mystery. Stays mystery-preserving — vibe,
/// match reasons, and unlocked clues only, never the title or venue — and is where
/// you commit: add to your plans solo, or bring one of your idle crews along.
private struct MysteryDetailView: View {
    @Environment(SessionStore.self) private var session
    let event: MysteryEvent
    let score: Double
    let reasons: [String]
    let hideCategory: Bool

    /// Drives the solo Apple Pay sheet. Solo plans are paid up front; crews are
    /// assigned for free and each member pays from the reveal room.
    @State private var showSoloCheckout = false

    private var claimed: Bool { session.quest(forEvent: event.id) != nil }
    private var attendingCrew: RSVPGroup? { session.crew(forEvent: event.id) }

    /// Crews without a mystery yet — eligible to receive this one. (One mystery
    /// per crew, so crews already on a quest are left out.)
    private var idleCrews: [RSVPGroup] {
        session.groups.filter { session.activeQuest(forCrew: $0.id) == nil }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.lg) {
                EventCard(event: event,
                          matchScore: claimed ? nil : score,
                          hideCategory: hideCategory)

                HStack(spacing: 12) {
                    factPill("clock",
                             "\(event.eventTime.formatted(style: .weekdayLong)) · \(event.eventTime.formatted(style: .time))")
                    factPill("location", "\(Int(event.distanceMiles)) mi away")
                }

                if !reasons.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Why this matches you", systemImage: "sparkles")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(reasons, id: \.self) { reason in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption).foregroundStyle(Theme.violet)
                                Text(reason).font(.subheadline).foregroundStyle(.secondary)
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .padding(Theme.Space.lg)
                    .glass(cornerRadius: Theme.Radius.md)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Clues so far", systemImage: "magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ClueList(event: event)
                }
                .padding(Theme.Space.lg)
                .glass(cornerRadius: Theme.Radius.md)

                if claimed { claimedSection } else { addSection }
            }
            .padding(Theme.Space.lg)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Mystery")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSoloCheckout) {
            ApplePayCheckoutSheet(event: event, crewName: nil) {
                add(crewID: nil)
                session.markPaid(event.id)
            }
        }
    }

    private var claimedSection: some View {
        VStack(spacing: 12) {
            Label(attendingCrew.map { "You're going with \($0.name)" } ?? "You said yes — going solo",
                  systemImage: "checkmark.seal.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            NavigationLink {
                RevealView(eventID: event.id)
            } label: {
                Label("Open the reveal room", systemImage: "eye.fill")
            }
            .buttonStyle(.primary)
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
        .gradientBorder(cornerRadius: Theme.Radius.md, lineWidth: 1)
    }

    private var addSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(event.price.ticketPriceText)
                    .font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
                Text("per person").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Label("Apple Pay", systemImage: "apple.logo")
                    .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }

            // Solo — pay up front to lock in your own spot.
            Text("Going solo? Pay now to lock it in — it stays a mystery until reveal day.")
                .font(.subheadline).foregroundStyle(.secondary)
            Button { showSoloCheckout = true } label: {
                Label("Reserve my spot", systemImage: "checkmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)

            // Crew — assign for free; each member pays from the reveal room.
            if !idleCrews.isEmpty {
                Divider().overlay(Theme.hairline).padding(.vertical, 2)
                Text("Or assign it to a crew")
                    .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                Text("No upfront payment — everyone pays their own ticket from the reveal room.")
                    .font(.caption).foregroundStyle(.secondary)
                ForEach(idleCrews) { crew in
                    Button { add(crewID: crew.id) } label: {
                        Label(crew.name, systemImage: crew.symbol)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.md)
    }

    private func add(crewID: String?) {
        Haptics.notify(.success)
        withAnimation { session.sayYes(to: event.id, crewID: crewID) }
    }

    private func factPill(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).font(.caption)
            Text(text).font(.caption.weight(.medium)).lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12).padding(.vertical, 8)
        .glass(cornerRadius: Theme.Radius.sm)
    }
}
