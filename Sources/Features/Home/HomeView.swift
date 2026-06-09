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
                                            crew: session.crew(forEvent: event.id))
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
                            .font(.title3).foregroundStyle(Theme.brandGradient)
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
        HStack(spacing: 6) {
            Image(systemName: "sparkles").foregroundStyle(Theme.ink)
            Text("e-z").font(.headline.weight(.bold)).foregroundStyle(Theme.ink)
                + Text(".rsvp").font(.headline.weight(.bold)).foregroundStyle(Theme.ink)
        }
    }
}

// MARK: - Headline card

private struct HeadlineMysteryCard: View {
    let event: MysteryEvent
    let crew: RSVPGroup?

    var body: some View {
        VStack(spacing: Theme.Space.lg) {
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
        .padding(Theme.Space.lg)
        .glass(cornerRadius: Theme.Radius.lg, strong: true)
        .gradientBorder(cornerRadius: Theme.Radius.lg)
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
