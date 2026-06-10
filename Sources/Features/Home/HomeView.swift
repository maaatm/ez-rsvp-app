import SwiftUI

struct HomeView: View {
    @Environment(SessionStore.self) private var session
    @State private var showStartMystery = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.xl) {
                    greeting

                    if session.events.isEmpty {
                        HeadlineSkeleton()
                    } else if let event = session.headlineEvent {
                        HeadlineMysteryCard(event: event,
                                            crew: session.crew(forEvent: event.id),
                                            revealed: session.isRevealed(event),
                                            unpaid: session.crew(forEvent: event.id) != nil
                                                && !session.hasPaid(event.id))
                        otherRSVPs
                    } else {
                        StartFirstMysteryCard { showStartMystery = true }
                    }

                    friendsStrip
                    crewsStrip
                }
                .padding(Theme.Space.lg)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { BrandWordmark() }
            }
            .refreshable { await session.refresh() }
            .sheet(isPresented: $showStartMystery) {
                QuestPreferencesSheet(crewID: nil)
            }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(timeGreeting)
                .font(.subheadline).foregroundStyle(.secondary)
            Text("\(session.currentUser?.firstName ?? "there") 👋")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
        }
    }

    private var timeGreeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case ..<12: return "Good morning,"
        case 12..<18: return "Good afternoon,"
        default: return "Good evening,"
        }
    }

    /// The events the user signed up for beyond the headline (next) one.
    private var otherSignedUp: [MysteryEvent] { Array(session.signedUpEvents.dropFirst()) }

    @ViewBuilder private var otherRSVPs: some View {
        if !otherSignedUp.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Your other RSVPs",
                              subtitle: "Everything else you've said yes to")
                ForEach(otherSignedUp) { event in
                    UpcomingMysteryRow(event: event, crew: session.crew(forEvent: event.id))
                }
            }
        }
    }

    private var friendsStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Happening now",
                          subtitle: "Your friends are saying yes")
            ForEach(session.activity.prefix(3)) { item in
                NavigationLink {
                    FriendProfileView(user: item.user)
                } label: {
                    ActivityRow(item: item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var crewsStrip: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Your crews")
            ForEach(session.groups) { crew in
                NavigationLink {
                    GroupDetailView(groupID: crew.id)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: crew.symbol)
                            .font(.title3).foregroundStyle(Theme.brandSolid)
                            .frame(width: 48, height: 48)
                            .glass(cornerRadius: Theme.Radius.sm)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(crew.name).font(.headline).foregroundStyle(Theme.ink)
                            Text(session.activeQuest(forCrew: crew.id) != nil
                                 ? "On a mystery · \(crew.goingCount) going"
                                 : "\(crew.members.count) members · idle")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .glass(cornerRadius: Theme.Radius.md)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct BrandWordmark: View {
    var body: some View {
        Text("e-z").font(.headline.weight(.bold)).foregroundStyle(Theme.ink)
            + Text(".rsvp").font(.headline.weight(.bold)).foregroundStyle(Theme.ink)
    }
}

// MARK: - Headline card

private struct HeadlineMysteryCard: View {
    let event: MysteryEvent
    let crew: RSVPGroup?
    var revealed: Bool = false
    /// True when this is a crew event the user still owes a ticket for.
    var unpaid: Bool = false

    var body: some View {
        VStack(spacing: Theme.Space.lg) {
            if unpaid { PaymentDueBanner(event: event) }
            if revealed { revealedContent } else { mysteryContent }
        }
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
    }

    // MARK: Still a mystery

    @ViewBuilder private var mysteryContent: some View {
        Badge(text: "Your upcoming mystery RSVP", systemImage: "sparkles", tint: Theme.violet)
            .frame(maxWidth: .infinity, alignment: .leading)

        MysteryBox(size: 160)

        HStack(spacing: 18) {
            Label(event.eventTime.formatted(style: .weekdayLong), systemImage: "calendar")
            Label(event.eventTime.formatted(style: .time), systemImage: "clock")
        }
        .font(.footnote).foregroundStyle(.secondary)

        VStack(spacing: 8) {
            Text("REVEALS IN").font(.caption2.weight(.bold)).tracking(2).foregroundStyle(.secondary)
            CountdownView(target: event.revealTime)
        }

        crewBlock

        VStack(alignment: .leading, spacing: 10) {
            Label("Your clues so far", systemImage: "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
            ClueList(event: event)
        }

        NavigationLink {
            RevealView(eventID: event.id)
        } label: {
            Label("Open the reveal room", systemImage: "eye.fill")
        }
        .buttonStyle(.primary)
    }

    // MARK: Revealed — full event, counting down to the start

    @ViewBuilder private var revealedContent: some View {
        Badge(text: "Revealed — you're going!", systemImage: "checkmark.seal.fill", tint: Theme.cyan)
            .frame(maxWidth: .infinity, alignment: .leading)

        EventHeroImage(event: event, height: 170, fallbackGlyphSize: 54)

        VStack(spacing: 6) {
            Text(event.title)
                .font(.system(.title2, design: .rounded).weight(.heavy))
                .multilineTextAlignment(.center)
            Text(event.eventDescription)
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }

        VStack(spacing: 8) {
            Text("STARTS IN").font(.caption2.weight(.bold)).tracking(2).foregroundStyle(.secondary)
            CountdownView(target: event.eventTime)
        }

        VStack(spacing: 10) {
            detailRow("calendar", event.eventTime.formatted(style: .weekdayLong),
                      event.eventTime.formatted(style: .time))
            detailRow("mappin.and.ellipse", event.venueName, event.generalArea)
            if let w = event.weather {
                detailRow(w.symbol, "\(w.temp)° · \(w.condition)", nil)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .glass(cornerRadius: Theme.Radius.sm)

        crewBlock

        NavigationLink {
            RevealView(eventID: event.id)
        } label: {
            Label("Directions & full details", systemImage: "arrow.up.right")
        }
        .buttonStyle(.primary)
    }

    private func detailRow(_ symbol: String, _ value: String, _ sub: String?) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).font(.subheadline).foregroundStyle(Theme.brandSolid)
                .frame(width: 22)
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.ink)
            if let sub {
                Text("· \(sub)").font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: Shared crew strip

    @ViewBuilder private var crewBlock: some View {
        if let crew {
            HStack {
                AvatarStack(users: crew.members.filter { $0.status == .going }.map(\.user))
                VStack(alignment: .leading, spacing: 1) {
                    Text("\(crew.goingCount) going").font(.subheadline.weight(.semibold))
                    Text(crew.name).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "person.2.fill").foregroundStyle(.secondary)
            }
            .padding(14)
            .glass(cornerRadius: Theme.Radius.sm)
        } else {
            HStack {
                Image(systemName: "person.fill").foregroundStyle(.secondary)
                Text("Going solo — invite a crew from Social").font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(14)
            .glass(cornerRadius: Theme.Radius.sm)
        }
    }
}

// MARK: - Compact RSVP row

/// A smaller card for the user's *other* signed-up mysteries, listed under the
/// headline. Mystery-preserving until reveal day — it shows the when, a live
/// countdown, and the crew, but not the title/venue. Tapping opens the reveal
/// room (or the revealed details, if the moment has passed).
private struct UpcomingMysteryRow: View {
    @Environment(SessionStore.self) private var session
    let event: MysteryEvent
    let crew: RSVPGroup?

    private var revealed: Bool { session.isRevealed(event) }
    private var unpaid: Bool { crew != nil && !session.hasPaid(event.id) }

    var body: some View {
        NavigationLink {
            RevealView(eventID: event.id)
        } label: {
            HStack(spacing: 14) {
                if revealed {
                    EventHeroImage(event: event, width: 52, height: 52,
                                   cornerRadius: Theme.Radius.sm, fallbackGlyphSize: 22)
                } else {
                    Image(systemName: "questionmark.diamond.fill")
                        .font(.title2).foregroundStyle(Theme.brandSolid)
                        .frame(width: 52, height: 52)
                        .glass(cornerRadius: Theme.Radius.sm)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(revealed ? event.title : "Mystery RSVP")
                        .font(.headline).foregroundStyle(Theme.ink).lineLimit(1)

                    Label("\(event.eventTime.formatted(style: .weekdayLong)) · \(event.eventTime.formatted(style: .time))",
                          systemImage: "calendar")
                        .font(.caption).foregroundStyle(.secondary).lineLimit(1)

                    HStack(spacing: 12) {
                        Label(revealed ? "Starts in \(event.daysUntilEvent())d" : "Reveals in \(event.daysUntilReveal())d",
                              systemImage: revealed ? "checkmark.seal.fill" : "clock")
                        if let crew {
                            Label("\(crew.goingCount)", systemImage: "person.2.fill")
                        }
                        if unpaid {
                            Label("Payment due", systemImage: "creditcard.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .font(.caption2.weight(.semibold)).foregroundStyle(Theme.violet)
                }

                Spacer(minLength: 8)
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            .padding(14)
            .glass(cornerRadius: Theme.Radius.md)
        }
        .buttonStyle(.plain)
    }
}

/// Shown when the user has no active quests.
private struct StartFirstMysteryCard: View {
    var onStart: () -> Void

    var body: some View {
        VStack(spacing: Theme.Space.lg) {
            MysteryBox(size: 140)
            VStack(spacing: 6) {
                Text("No mystery yet").font(.title3.weight(.bold))
                Text("Say yes to your first surprise — we'll match you to something you'll love.")
                    .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            Button(action: onStart) {
                Label("Find my mystery", systemImage: "sparkles")
            }
            .buttonStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
    }
}

private struct HeadlineSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: Theme.Radius.lg).fill(Theme.surfaceSunken).frame(height: 360)
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}
